//
//  MainViewController.swift
//  RESTAPP
//
//  Created by Артём on 28.03.2025.
//

//
//  MainViewController.swift
//  RESTAPP
//
//  Created by Артём on 28.03.2025.
//

import UIKit
import SDWebImage

// MARK: - Display Logic
protocol MainDisplayLogic: AnyObject {
    func displayFood(viewModel: Main.LoadFood.ViewModel)
}

// MARK: - MainViewController
final class MainViewController: UIViewController, MainDisplayLogic {
    
    // MARK: - Properties
    private var domainCategories: [FoodCategory] = []
    private var categories: [FoodCategoryViewModel] = []
    var interactor: MainBusinessLogic?
    var router: (NSObjectProtocol & MainRoutingLogic)?
    
    // MARK: - UI Elements
    private let canteenLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "person.circle"), for: .normal)
        button.addTarget(nil, action: #selector(profileTapped), for: .touchUpInside)
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 24
        return sv
    }()
    
    private let cartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "cart.fill"), for: .normal)
        button.backgroundColor = UIColor(hex: "FF9700")
        button.tintColor = .white
        button.layer.cornerRadius = 30
        button.addTarget(nil, action: #selector(cartTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializer
    init(interactor: MainBusinessLogic, router: (NSObjectProtocol & MainRoutingLogic)) {
        self.interactor = interactor
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        interactor?.loadFood(request: .init())
    }
    
    // MARK: - UI Configuration
    private func configureUI() {
        view.backgroundColor = .systemBackground
        setupCanteenPanel()
        setupScrollView()
        setupStackView()
        setupCartButton()
    }
    
    // MARK: - Setup Canteen Panel
    private func setupCanteenPanel() {
        view.addSubview(canteenLabel)
        view.addSubview(profileButton)
        canteenLabel.pinTop(to: view.safeAreaLayoutGuide, 16)
        canteenLabel.pinLeft(to: view, 20)
        profileButton.pinCenterY(to: canteenLabel)
        profileButton.pinRight(to: view, 20)
        canteenLabel.text = "Столовая №1"
    }
    
    // MARK: - Setup ScrollView
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.pinTop(to: canteenLabel.bottomAnchor, 16)
        scrollView.pinLeft(to: view, 0)
        scrollView.pinRight(to: view, 0)
        scrollView.pinBottom(to: view, 0)
    }
    
    // MARK: - Setup StackView
    private func setupStackView() {
        scrollView.addSubview(stackView)
        stackView.pinTop(to: scrollView.topAnchor, 0)
        stackView.pinLeft(to: scrollView, 16)
        stackView.pinRight(to: scrollView, 16)
        stackView.pinBottom(to: scrollView.bottomAnchor, 0)
        stackView.pinWidth(to: scrollView.widthAnchor, -32)
    }
    
    // MARK: - Setup Cart Button
    private func setupCartButton() {
        view.addSubview(cartButton)
        cartButton.pinRight(to: view, 24)
        cartButton.pinBottom(to: view.safeAreaLayoutGuide, 24)
        cartButton.setWidth(60)
        cartButton.setHeight(60)
    }
    
    // MARK: - Display Logic
    func displayFood(viewModel: Main.LoadFood.ViewModel) {
        self.categories = viewModel.categories
        self.domainCategories = viewModel.domainCategories
        renderCategories()
    }
    
    // MARK: - Render Categories
    private func renderCategories() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (catIndex, categoryVM) in categories.enumerated() {
            let titleLabel = UILabel()
            titleLabel.font = .boldSystemFont(ofSize: 18)
            titleLabel.text = categoryVM.title
            
            let scroll = UIScrollView()
            scroll.showsHorizontalScrollIndicator = false
            scroll.setHeight(200)
            scroll.alwaysBounceVertical = false
            scroll.bounces = false
            
            let hStack = UIStackView()
            hStack.axis = .horizontal
            hStack.spacing = 16
            hStack.translatesAutoresizingMaskIntoConstraints = false
            
            let domainCat = domainCategories[catIndex]
            for (mealIndex, mealVM) in categoryVM.meals.enumerated() {
                let domainMeal = domainCat.meals[mealIndex]
                let card = createMealCard(mealVM: mealVM, domainMeal: domainMeal)
                hStack.addArrangedSubview(card)
            }
            
            scroll.addSubview(hStack)
            hStack.pinTop(to: scroll, 8)
            hStack.pinBottom(to: scroll, 8)
            hStack.pinLeft(to: scroll, 8)
            hStack.pinRight(to: scroll, 8)
            hStack.pinHeight(to: scroll, 1.0)
            
            let container = UIStackView(arrangedSubviews: [titleLabel, scroll])
            container.axis = .vertical
            container.spacing = 8
            
            stackView.addArrangedSubview(container)
        }
    }
    
    // MARK: - Create Meal Card
    private var mealByView: [UIView: Meal] = [:]
    
    private func createMealCard(mealVM: MealViewModel, domainMeal: Meal) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 10
        card.setWidth(140)
        
        let mealImageView = UIImageView()
        mealImageView.contentMode = .scaleAspectFill
        mealImageView.clipsToBounds = true
        mealImageView.layer.cornerRadius = 10
        mealImageView.setHeight(80)
        if let url = URL(string: mealVM.imageName) {
            mealImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        }
        
        let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 14)
        nameLabel.numberOfLines = 2
        nameLabel.text = mealVM.name
        
        let priceLabel = UILabel()
        priceLabel.font = .boldSystemFont(ofSize: 14)
        priceLabel.textColor = .systemGreen
        priceLabel.text = mealVM.priceText
        
        var config = UIButton.Configuration.filled()
        config.title = "+"
        config.baseBackgroundColor = UIColor(hex: "FF9700")
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        let plusButton = UIButton(configuration: config)
        plusButton.addAction(UIAction(handler: { _ in
            CartService.shared.add(meal: domainMeal)
        }), for: .touchUpInside)
        
        let vStack = UIStackView(arrangedSubviews: [mealImageView, nameLabel, priceLabel, plusButton])
        vStack.axis = .vertical
        vStack.spacing = 8
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(vStack)
        vStack.pinTop(to: card, 8)
        vStack.pinLeft(to: card, 8)
        vStack.pinRight(to: card, 8)
        vStack.pinBottom(to: card, 8)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(mealCardTapped(_:)))
        card.addGestureRecognizer(tap)
        card.isUserInteractionEnabled = true
        mealByView[card] = domainMeal
        
        return card
    }
    
    // MARK: - Actions
    @objc private func mealCardTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view, let meal = mealByView[view] else { return }
        router?.routeToMealDetail(meal: meal)
    }
    
    @objc private func cartTapped() {
        router?.routeToCart()
    }
    
    @objc private func profileTapped() {
        router?.routeToProfile()
    }
}
