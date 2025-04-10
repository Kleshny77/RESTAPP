//
//  MainViewController.swift
//  RESTAPP
//
//  Created by Артём on 29.03.2025.
//

import UIKit
import Foundation

// MARK: – DisplayLogic
protocol MainDisplayLogic: AnyObject {
    func displayFood(viewModel: Main.LoadFood.ViewModel)
    func displayRestaurants(viewModel: Main.LoadRestaurants.ViewModel)
    func displaySelectedRestaurant(viewModel: Main.SelectRestaurant.ViewModel)
}

private struct Section: Hashable {
    let id = UUID()
    let title: String
    let meals: [Meal]
}
private enum Item: Hashable {
    case meal(Meal)
}

// MARK: – MainViewController
final class MainViewController: UIViewController {
    private let interactor: MainBusinessLogic
    private let router: (NSObjectProtocol & MainRoutingLogic)
    
    // MARK: – Init
    init(interactor: MainBusinessLogic,
         router: (NSObjectProtocol & MainRoutingLogic)) {
        self.interactor = interactor
        self.router     = router
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: – UI
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var cartButtonWidthConstraint: NSLayoutConstraint?
    
    private let cartButton: BouncyButton = {
        let b = BouncyButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "cart.fill"), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor(hex: "35C759")
        b.layer.cornerRadius = 30
        return b
    }()
    
    private lazy var loadingView: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isHidden = true
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        overlay.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        ])
        return overlay
    }()
    
    private lazy var closedOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground.withAlphaComponent(0.95)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 12
        
        let imageView = UIImageView(image: UIImage(systemName: "clock.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Извините, сейчас заведение закрыто"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textAlignment = .center
        label.textColor = .systemGray
        label.numberOfLines = 0
        
        let scheduleLabel = UILabel()
        scheduleLabel.translatesAutoresizingMaskIntoConstraints = false
        scheduleLabel.font = .systemFont(ofSize: 15)
        scheduleLabel.textColor = .systemGray2
        scheduleLabel.numberOfLines = 0
        
        container.addSubview(imageView)
        container.addSubview(label)
        container.addSubview(scheduleLabel)
        view.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 48),
            imageView.widthAnchor.constraint(equalToConstant: 48),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            
            scheduleLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            scheduleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            scheduleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            scheduleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24)
        ])
        
        view.accessibilityElements = [scheduleLabel]
        return view
    }()
    
    // MARK: – State
    private var sections: [Section] = []
    private var isRestaurantOpen: Bool = false {
        didSet { updateClosedState() }
    }
    
    // MARK: – Life‑cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configureNavBar()
        makeCollectionView()
        makeCartButton()
        setupClosedOverlay()
        setupLoadingOverlay()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(cartDidChange),
                                               name: .cartDidChange,
                                               object: nil)
        
        showLoading()
        
        Task {
            do {
                try await RestaurantService.shared.loadLastSelectedRestaurant()
                if let restaurant = RestaurantService.shared.currentRestaurant {
                    (navigationItem.titleView as? UIButton)?.setTitle(restaurant.name, for: .normal)
                    isRestaurantOpen = restaurant.isOpen
                }
                interactor.loadFood(request: .init())
            } catch {
                print("Error loading last restaurant:", error)
                interactor.loadFood(request: .init())
            }
        }
        
        startOpenStatusTimer()
    }
    
    // MARK: – Loading overlay helpers
    private func setupLoadingOverlay() {
        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    private func showLoading() {
        loadingView.alpha = 0
        loadingView.isHidden = false
        UIView.animate(withDuration: 0.25) { self.loadingView.alpha = 1 }
    }
    private func hideLoading() {
        UIView.animate(withDuration: 0.25, animations: {
            self.loadingView.alpha = 0
        }) { _ in self.loadingView.isHidden = true }
    }
    
    // MARK: – NavBar
    private func configureNavBar() {
        var config = UIButton.Configuration.plain()
        config.title           = RestaurantService.shared.currentRestaurant?.name
        ?? "Загрузка столовых…"
        config.image           = UIImage(systemName: "chevron.down")
        config.imagePlacement  = .trailing
        config.imagePadding    = 4
        config.contentInsets   = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let restaurantButton = UIButton(configuration: config, primaryAction: nil)
        restaurantButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        restaurantButton.addTarget(self,
                                   action: #selector(restaurantButtonTapped),
                                   for: .touchUpInside)
        
        restaurantButton.titleLabel?.lineBreakMode  = .byTruncatingTail
        restaurantButton.titleLabel?.numberOfLines  = 1
        let maxWidth = UIScreen.main.bounds.width * 0.7
        restaurantButton.widthAnchor
            .constraint(lessThanOrEqualToConstant: maxWidth).isActive = true
        restaurantButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        restaurantButton.setContentHuggingPriority(.defaultLow,              for: .horizontal)
        
        navigationItem.titleView = restaurantButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.circle"),
            style: .plain,
            target: self,
            action: #selector(profileTapped)
        )
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor     = UIColor.black.withAlphaComponent(0.26)
        
        navigationController?.navigationBar.standardAppearance   = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance    = appearance
        navigationController?.navigationBar.tintColor            = .black
    }
    
    @objc private func restaurantButtonTapped() {
        interactor.loadRestaurants(request: .init())
    }
    
    private func makeCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        collectionView.pinTop(to: view.safeAreaLayoutGuide)
        collectionView.pinLeft(to: view)
        collectionView.pinRight(to: view)
        collectionView.pinBottom(to: view)
        
        collectionView.register(MainMealCell.self, forCellWithReuseIdentifier: MainMealCell.reuseID)
        collectionView.register(SectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionHeader.reuseID)
        
        dataSource = .init(collectionView: collectionView) { cv, indexPath, item in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: MainMealCell.reuseID, for: indexPath) as! MainMealCell
            if case let .meal(meal) = item { cell.configure(with: meal) }
            return cell
        }
        
        dataSource.supplementaryViewProvider = { [weak self] cv, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader,
                  let header = cv.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: SectionHeader.reuseID,
                                                                   for: indexPath) as? SectionHeader,
                  let section = self?.sections[indexPath.section] else { return nil }
            header.title = section.title
            return header
        }
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(140),
                                              heightDimension: .absolute(215))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 10, leading: 16, bottom: 24, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader,
                                                                 alignment: .topLeading)
        section.boundarySupplementaryItems = [header]
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func makeCartButton() {
        view.addSubview(cartButton)
        cartButton.pinBottom(to: view.safeAreaLayoutGuide)
        cartButton.pinRight(to: view, 12)
        cartButtonWidthConstraint = cartButton.setWidth(mode: .equal, 60)
        cartButton.setHeight(60)
        cartButton.addTarget(self, action: #selector(cartTapped), for: .touchUpInside)
    }
    
    @objc private func cartDidChange() {
        for path in collectionView.indexPathsForVisibleItems {
            guard let cell = collectionView.cellForItem(at: path) as? MainMealCell else { continue }
            let meal = sections[path.section].meals[path.item]
            let newCount = CartService.shared.getAllItems().first { $0.meal == meal }?.count ?? 0
            newCount > 0 ? cell.updateCounter(to: newCount) : cell.resetToPriceButton()
        }
        
        let totalCount = CartService.shared.getAllItems().reduce(0) { $0 + $1.count }
        let totalPrice = CartService.shared.getAllItems().reduce(0) { $0 + $1.count * $1.meal.price }
        totalCount > 0 ? activateCartButton(count: totalCount, price: totalPrice) : deactivateCartButton()
    }
    
    private func activateCartButton(count: Int, price: Int) {
        cartButton.setImage(nil, for: .normal)
        cartButton.setTitle("\(price) ₽", for: .normal)
        cartButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        cartButtonWidthConstraint?.constant = 100
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.8) { self.view.layoutIfNeeded() }
    }
    private func deactivateCartButton() {
        cartButton.setTitle(nil, for: .normal)
        cartButton.setImage(UIImage(systemName: "cart.fill"), for: .normal)
        cartButtonWidthConstraint?.constant = 60
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.8) { self.view.layoutIfNeeded() }
    }
    
    private func setupClosedOverlay() {
        view.addSubview(closedOverlay)
        NSLayoutConstraint.activate([
            closedOverlay.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            closedOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            closedOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            closedOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        if let restaurant = RestaurantService.shared.currentRestaurant,
           let scheduleLabel = closedOverlay.accessibilityElements?.first as? UILabel {
            isRestaurantOpen = restaurant.isOpen
            scheduleLabel.text = "Расписание работы:\n\n\(restaurant.openingHours.fullSchedule)"
        }
    }
    
    private func updateClosedState() {
        UIView.animate(withDuration: 0.3) {
            self.closedOverlay.alpha = self.isRestaurantOpen ? 0 : 1
        } completion: { _ in
            self.closedOverlay.isHidden = self.isRestaurantOpen
        }
        collectionView.isUserInteractionEnabled = isRestaurantOpen
        cartButton.isEnabled = isRestaurantOpen
    }
    
    private func startOpenStatusTimer() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self = self,
                  let restaurant = RestaurantService.shared.currentRestaurant else { return }
            let previous = self.isRestaurantOpen
            self.isRestaurantOpen = restaurant.isOpen
            if previous != self.isRestaurantOpen {
                self.updateClosedState()
            }
        }
    }
}

// MARK: – UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let meal = sections[indexPath.section].meals[indexPath.item]
        router.routeToMealDetail(meal: meal)
    }
}

// MARK: – MainDisplayLogic
extension MainViewController: MainDisplayLogic {
    func displayFood(viewModel: Main.LoadFood.ViewModel) {
        hideLoading()
        sections = zip(viewModel.categories, viewModel.domainCategories).map { vm, domain in
            Section(title: vm.title, meals: domain.meals)
        }
        var snap = NSDiffableDataSourceSnapshot<Section, Item>()
        for sec in sections {
            snap.appendSections([sec])
            snap.appendItems(sec.meals.map(Item.meal))
        }
        dataSource.apply(snap, animatingDifferences: true)
    }
    
    func displayRestaurants(viewModel: Main.LoadRestaurants.ViewModel) {
        let selector = RestaurantSelectorViewController()
        selector.delegate = self
        Task {
            do {
                let restaurants = try await RestaurantService.shared.fetchRestaurants()
                await MainActor.run {
                    selector.configure(with: restaurants)
                    let nav = UINavigationController(rootViewController: selector)
                    self.present(nav, animated: true)
                }
            } catch { print("Error loading restaurants: \(error)") }
        }
    }
    
    func displaySelectedRestaurant(viewModel: Main.SelectRestaurant.ViewModel) {
        (navigationItem.titleView as? UIButton)?.setTitle(viewModel.name, for: .normal)
        showLoading()
    }
}

// MARK: – RestaurantSelectorDelegate
extension MainViewController: RestaurantSelectorDelegate {
    func restaurantSelectorDidSelect(_ restaurant: Restaurant) {
        interactor.selectRestaurant(request: .init(restaurantId: restaurant.id))
        isRestaurantOpen = restaurant.isOpen
        if let scheduleLabel = closedOverlay.accessibilityElements?.first as? UILabel {
            scheduleLabel.text = "Расписание работы:\n\n\(restaurant.openingHours.fullSchedule)"
        }
    }
}

// MARK: – Button targets
@objc private extension MainViewController {
    func cartTapped()    { router.routeToCart() }
    func profileTapped() { router.routeToProfile() }
}

// MARK: – BouncyButton
final class BouncyButton: UIButton {
    override var isHighlighted: Bool {
        didSet { animate(isHighlighted) }
    }
    private func animate(_ pressed: Bool) {
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.transform = pressed ? CGAffineTransform(scaleX: 0.94, y: 0.94) : .identity
            self.alpha = pressed ? 0.8 : 1.0
        }
    }
}

// MARK: – SectionHeader
final class SectionHeader: UICollectionReusableView {
    
    static let reuseID = "SectionHeader"
    private let backgroundContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        return v
    }()
    
    private let label: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .medium)
        l.textColor = .label
        return l
    }()
    
    var title: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(backgroundContainer)
        backgroundContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundContainer.topAnchor.constraint(equalTo: topAnchor),
            backgroundContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -32),
            backgroundContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 32)
        ])
        
        backgroundContainer.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: backgroundContainer.trailingAnchor),
            label.topAnchor.constraint(equalTo: backgroundContainer.topAnchor, constant: 2),
            label.bottomAnchor.constraint(equalTo: backgroundContainer.bottomAnchor, constant: -2)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
