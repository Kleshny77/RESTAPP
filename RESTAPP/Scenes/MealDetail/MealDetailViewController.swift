//
//  MealDetailViewController.swift
//  RESTAPP
//
//  Created by Артём on 02.04.2025.
//

import UIKit

// MARK: – Display Logic
protocol MealDetailDisplayLogic: AnyObject {
    func displayMeal(viewModel: MealDetail.Load.ViewModel)
}

// MARK: – MealDetailViewController
final class MealDetailViewController: UIViewController, MealDetailDisplayLogic {
    
    // MARK: – Dependencies 
    var interactor: (MealDetailBusinessLogic & MealDetailDataStore)?
    
    // MARK: – Properties
    private var currentMeal: Meal? { interactor?.meal }
    private var isRestaurantOpen: Bool {
        RestaurantService.shared.currentRestaurant?.isOpen ?? false
    }
    
    // MARK: – UI
    private let scrollView   = UIScrollView()
    private let imageView    = UIImageView()
    private let nameLabel    = UILabel()
    private let weightLabel  = UILabel()
    private let descriptionLabel = UILabel()
    private let nutritionLabel   = UILabel()
    private let compositionLabel = UILabel()
    private let closedLabel      = UILabel()
    private let counterButton    = CounterButton()
    
    // MARK: – Init
    init() { super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    // MARK: – Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startOpenStatusTimer()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cartDidChange),
            name: .cartDidChange,
            object: nil
        )
        
        interactor?.loadMeal(request: .init())
    }
    
    // MARK: – UI-setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        configureSubviews()
        layoutSubviewsManually()
        updateClosedState()
    }
    
    private func configureSubviews() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 6
        
        nameLabel.font = .boldSystemFont(ofSize: 26)
        weightLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        weightLabel.textColor = .darkGray
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .systemFont(ofSize: 18)
        
        nutritionLabel.numberOfLines = 0
        nutritionLabel.font = .systemFont(ofSize: 16)
        nutritionLabel.textColor = .darkGray
        
        compositionLabel.numberOfLines = 0
        compositionLabel.font = .italicSystemFont(ofSize: 18)
        compositionLabel.textColor = .darkGray
        
        closedLabel.font = .systemFont(ofSize: 15, weight: .medium)
        closedLabel.textAlignment = .center
        closedLabel.textColor = .systemGray
        closedLabel.backgroundColor = .systemGray6
        closedLabel.layer.cornerRadius = 8
        closedLabel.clipsToBounds = true
        closedLabel.numberOfLines = 0
        
        counterButton.onIncrease = { [weak self] in
            guard let meal = self?.currentMeal else { return }
            CartService.shared.add(meal: meal)
        }
        counterButton.onDecrease = { [weak self] in
            guard let meal = self?.currentMeal else { return }
            CartService.shared.remove(meal: meal)
        }
    }
    
    private func layoutSubviewsManually() {
        [imageView, nameLabel, weightLabel,
         descriptionLabel, nutritionLabel,
         compositionLabel, counterButton, closedLabel]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            
            weightLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            weightLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: weightLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            nutritionLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            nutritionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            nutritionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            compositionLabel.topAnchor.constraint(equalTo: nutritionLabel.bottomAnchor, constant: 8),
            compositionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            compositionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            counterButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            counterButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            counterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            counterButton.heightAnchor.constraint(equalToConstant: 50),
            
            closedLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            closedLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            closedLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            closedLabel.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: – Helpers
    private func startOpenStatusTimer() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateClosedState()
        }
    }
    
    private func updateClosedState() {
        counterButton.isHidden = !isRestaurantOpen
        closedLabel.isHidden   =  isRestaurantOpen
        if !isRestaurantOpen,
           let rest = RestaurantService.shared.currentRestaurant {
            closedLabel.text = """
              Извините, заведение закрыто
              Сегодня: \(rest.openingHours.currentDaySchedule)
              """
        }
    }
    
    // MARK: – Cart observer
    @objc private func cartDidChange() {
        guard let meal = currentMeal else { return }
        let count = CartService.shared
            .getAllItems()
            .first(where: { $0.meal == meal })?
            .count ?? 0
        counterButton.updateCount(count)
    }
    
    // MARK: – DisplayLogic
    func displayMeal(viewModel: MealDetail.Load.ViewModel) {
        nameLabel.text        = viewModel.name
        weightLabel.text      = viewModel.weightText
        descriptionLabel.text = viewModel.description
        nutritionLabel.text   = """
            \(viewModel.kcalText)
            \(viewModel.proteinText)
            \(viewModel.fatText)
            \(viewModel.carbsText)
            """
        compositionLabel.text = "Состав: \(viewModel.composition)"
        
        if let meal = currentMeal {
            counterButton.configure(price: meal.price)
            let count = CartService.shared
                .getAllItems()
                .first(where: { $0.meal == meal })?
                .count ?? 0
            counterButton.updateCount(count)
        }
        
        Task { await imageView.loadImageAsync(from: viewModel.imageURL) }
        updateClosedState()
    }
}
