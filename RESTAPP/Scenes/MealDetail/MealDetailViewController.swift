//
//  MealDetailViewController.swift
//  RESTAPP
//
//  Created by Артём on 02.04.2025.
//

import UIKit

// MARK: - Display Logic
protocol MealDetailDisplayLogic: AnyObject {
    func displayMeal(viewModel: MealDetail.Load.ViewModel)
}

// MARK: - MealDetailViewController
final class MealDetailViewController: UIViewController, MealDetailDisplayLogic {
    
    // MARK: - Properties
    var interactor: (MealDetailBusinessLogic & MealDetailDataStore)?
    private var currentMeal: Meal?
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 22)
        label.numberOfLines = 0
        return label
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let weightLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textColor = .systemGreen
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Закрыть", for: .normal)
        return button
    }()
    
    private let addToCartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить в корзину", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - Initializer
    init(meal: Meal) {
        super.init(nibName: nil, bundle: nil)
        setup(with: meal)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        configureAddButton()
        interactor?.loadMeal(request: .init(mealID: currentMeal?.id ?? ""))
    }
    
    // MARK: - Setup
    private func setup(with meal: Meal) {
        let interactor = MealDetailInteractor()
        let presenter = MealDetailPresenter()
        self.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = self
        interactor.meal = meal
    }
    
    // MARK: - UI Configuration
    private func configureUI() {
        let stack = UIStackView(arrangedSubviews: [imageView, nameLabel, weightLabel, priceLabel, closeButton])
        stack.axis = .vertical
        stack.spacing = 16
        view.addSubview(stack)
        stack.pinTop(to: view.safeAreaLayoutGuide, 20)
        stack.pinLeft(to: view, 20)
        stack.pinRight(to: view, 20)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }
    
    private func configureAddButton() {
        view.addSubview(addToCartButton)
        addToCartButton.pinLeft(to: view, 20)
        addToCartButton.pinRight(to: view, 20)
        addToCartButton.pinBottom(to: view.safeAreaLayoutGuide, 16)
        addToCartButton.setHeight(mode: .equal, 50)
        addToCartButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func addToCartTapped() {
        guard let meal = currentMeal else { return }
        CartService.shared.add(meal: meal)
        dismiss(animated: true)
    }
    
    // MARK: - Display Logic
    func displayMeal(viewModel: MealDetail.Load.ViewModel) {
        nameLabel.text = viewModel.name
        weightLabel.text = viewModel.weightText
        priceLabel.text = viewModel.priceText
        if URL(string: viewModel.imageName) != nil {
            Task { await imageView.loadImageAsync(from: viewModel.imageName) }
        }
        currentMeal = Meal(
            id: viewModel.id,
            name: viewModel.name,
            imageURL: viewModel.imageName,
            price: viewModel.price,
            description: viewModel.description,
            weight: viewModel.weight
        )
    }
}
