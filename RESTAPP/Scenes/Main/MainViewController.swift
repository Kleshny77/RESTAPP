//
//  MainViewController.swift
//  RESTAPP
//
//  Created by Артём on 28.03.2025.
//

import UIKit
//import SDWebImage

// MARK: – DisplayLogic
protocol MainDisplayLogic: AnyObject {
    func displayFood(viewModel: Main.LoadFood.ViewModel)
}

private struct Section: Hashable {
    let id = UUID()
    let title: String
    let meals: [Meal]
}
private enum Item: Hashable {
    case meal(Meal)
}

final class MainViewController: UIViewController, MainDisplayLogic {

    // MARK: DI
    private let interactor: MainBusinessLogic
    private let router: (NSObjectProtocol & MainRoutingLogic)

    init(interactor: MainBusinessLogic,
         router: (NSObjectProtocol & MainRoutingLogic)) {
        self.interactor = interactor
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: UI
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var cartButtonWidthConstraint: NSLayoutConstraint?

    private let cartButton: BouncyButton = {
        let b = BouncyButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "cart.fill"), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor(hex: "FF9700")
        b.layer.cornerRadius = 30
        return b
    }()

    // MARK: State
    private var sections: [Section] = []

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavBar()
        makeCollectionView()
        makeCartButton()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cartDidChange),
            name: .cartDidChange,
            object: nil
        )

        interactor.loadFood(request: .init())
    }

    // MARK: – NavBar + Shadow
    private func configureNavBar() {
        navigationItem.title = "Столовая №1"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.circle"),
            style: .plain,
            target: self,
            action: #selector(profileTapped)
        )

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.26)
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .black
    }



    // MARK: – CollectionView
    private func makeCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        collectionView.canCancelContentTouches = false
        collectionView.pinHorizontal(to: view)
        collectionView.pinBottom(to: view)
        collectionView.pinTop(to: view.safeAreaLayoutGuide)

        collectionView.register(MainMealCell.self,
                                forCellWithReuseIdentifier: MainMealCell.reuseID)
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
                  let header = cv.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: SectionHeader.reuseID,
                    for: indexPath) as? SectionHeader,
                  let section = self?.sections[indexPath.section]
            else { return nil }
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
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .topLeading)
        header.pinToVisibleBounds = false
        header.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)

        section.boundarySupplementaryItems = [header]
        let config = UICollectionViewCompositionalLayoutConfiguration()
        return UICollectionViewCompositionalLayout(section: section, configuration: config)
    }

    // MARK: – Cart FAB
    private func makeCartButton() {
        view.addSubview(cartButton)
        cartButton.pinBottom(to: view.safeAreaLayoutGuide)
        cartButton.pinRight(to: view, 12)
        cartButtonWidthConstraint = cartButton.setWidth(mode: .equal, 60)
        cartButton.setHeight(60)
        cartButton.addTarget(self, action: #selector(cartTapped), for: .touchUpInside)
    }

    @objc private func cartDidChange() {
        for ip in collectionView.indexPathsForVisibleItems {
            guard let cell = collectionView.cellForItem(at: ip) as? MainMealCell else { continue }
            let meal = sections[ip.section].meals[ip.item]
            let newCount = CartService.shared.getAllItems().first { $0.meal == meal }?.count ?? 0
            if newCount > 0 {
                cell.updateCounter(to: newCount)
            } else {
                cell.resetToPriceButton()
            }
        }

        let items = CartService.shared.getAllItems()
        let totalCount = items.reduce(0) { $0 + $1.count }
        let totalPrice = items.reduce(0) { $0 + $1.count * $1.meal.price }

        if totalCount > 0 {
            activateCartButton(count: totalCount, price: totalPrice)
        } else {
            deactivateCartButton()
        }
    }

    private func activateCartButton(count: Int, price: Int) {
        cartButton.setImage(nil, for: .normal)
        cartButton.setTitle("\(price) ₽", for: .normal)
        cartButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        cartButtonWidthConstraint?.constant = 100

        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.8,
                       options: [.allowUserInteraction]) {
            self.view.layoutIfNeeded()
        }
    }

    private func deactivateCartButton() {
        cartButton.setTitle(nil, for: .normal)
        cartButton.setImage(UIImage(systemName: "cart.fill"), for: .normal)
        cartButtonWidthConstraint?.constant = 60

        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.8,
                       options: [.allowUserInteraction]) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: – DisplayLogic
    func displayFood(viewModel: Main.LoadFood.ViewModel) {
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
}

// MARK: – UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let meal = sections[indexPath.section].meals[indexPath.item]
        router.routeToMealDetail(meal: meal)
    }
}

// MARK: – Actions
@objc private extension MainViewController {
    func cartTapped()    { router.routeToCart() }
    func profileTapped() { router.routeToProfile() }
}

final class SectionHeader: UICollectionReusableView {
    
    static let reuseID = "SectionHeader"

    private let backgroundContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemBackground // <-- любой фон
        return v
    }()

    private let label: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .medium)
        return l
    }()
    
    var title: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(backgroundContainer)
        backgroundContainer.pinVertical(to: self)
        backgroundContainer.pinHorizontal(to: self, -32)

        backgroundContainer.addSubview(label)
        label.pinTop(to: backgroundContainer, 2)
        label.pinBottom(to: backgroundContainer)
        label.pinHorizontal(to: backgroundContainer, 20)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

final class BouncyButton: UIButton {
    override var isHighlighted: Bool {
        didSet { animate(isHighlighted) }
    }

    private func animate(_ pressed: Bool) {
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       options: [.curveEaseOut, .allowUserInteraction],
                       animations: {
            self.transform = pressed ? CGAffineTransform(scaleX: 0.94, y: 0.94) : .identity
            self.alpha = pressed ? 0.8 : 1.0
        })
    }
}
