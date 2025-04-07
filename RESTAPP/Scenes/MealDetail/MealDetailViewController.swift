import UIKit

// MARK: - Display Logic
protocol MealDetailDisplayLogic: AnyObject {
    func displayMeal(viewModel: MealDetail.Load.ViewModel)
}

// MARK: - MealDetailViewController
final class MealDetailViewController: UIViewController, MealDetailDisplayLogic {

    // MARK: - Properties
    private var currentMeal: Meal?
    private var isRestaurantOpen: Bool {
        RestaurantService.shared.currentRestaurant?.isOpen ?? false
    }
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray6
        iv.layer.cornerRadius = 6
        return iv
    }()
    
    private let counterButton = CounterButton()
    
    private let closedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .systemGray
        label.backgroundColor = .systemGray6
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.isHidden = true
        label.numberOfLines = 0
        return label
    }()

    // MARK: — UI
    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 26, weight: .bold)
        l.lineBreakMode = .byTruncatingTail
        l.numberOfLines = 1
        l.setContentHuggingPriority(.required, for: .vertical)
        l.setContentCompressionResistancePriority(.required, for: .vertical)
        return l
    }()

    private let weightLabel: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 20, weight: .semibold)
        l.textColor = .darkGray
        l.setContentHuggingPriority(.required, for: .vertical)
        l.setContentCompressionResistancePriority(.required, for: .vertical)
        return l
    }()

    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 18, weight: .regular)
        l.numberOfLines = 0
        l.setContentHuggingPriority(.required, for: .vertical)
        l.setContentCompressionResistancePriority(.required, for: .vertical)
        return l
    }()

    private let nutritionLabel: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 16, weight: .regular)
        l.textColor     = .darkGray
        l.numberOfLines = 0
        l.setContentHuggingPriority(.required, for: .vertical)
        l.setContentCompressionResistancePriority(.required, for: .vertical)
        return l
    }()

    private let compositionLabel: UILabel = {
        let l = UILabel()
        l.font          = .italicSystemFont(ofSize: 18)
        l.textColor     = .darkGray
        l.numberOfLines = 0
        l.setContentHuggingPriority(.required, for: .vertical)
        l.setContentCompressionResistancePriority(.required, for: .vertical)
        return l
    }()

    // MARK: — Interactor
    var interactor: (MealDetailBusinessLogic & MealDetailDataStore)?

    // MARK: — Init
    init(meal: Meal) {
        super.init(nibName: nil, bundle: nil)
        let interactor = MealDetailInteractor()
        let presenter  = MealDetailPresenter()
        self.interactor      = interactor
        interactor.presenter = presenter
        presenter.viewController = self
        interactor.meal      = meal
        
        // Подписываемся на изменения корзины
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cartDidChange),
            name: .cartDidChange,
            object: nil
        )
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: — Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cartDidChange),
            name: .cartDidChange,
            object: nil
        )
        
        // Запускаем таймер для проверки статуса открытия
        startOpenStatusTimer()
        
        interactor?.loadMeal(request: .init(mealID: ""))
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        configureImageView()
        configureNameLabel()
        configureWeightLabel()
        configureDescriptionLabel()
        configureNutritionLabel()
        configureCompositionLabel()
        configureCounterButton()

        // Add closed label
        view.addSubview(closedLabel)
        NSLayoutConstraint.activate([
            closedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closedLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            closedLabel.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        updateClosedState()
    }

    private func updateClosedState() {
        counterButton.isHidden = !isRestaurantOpen
        closedLabel.isHidden = isRestaurantOpen
        
        if !isRestaurantOpen, let restaurant = RestaurantService.shared.currentRestaurant {
            closedLabel.text = """
                Извините, сейчас заведение закрыто
                Сегодня: \(restaurant.openingHours.currentDaySchedule)
                """
        }
    }

    private func startOpenStatusTimer() {
        // Проверяем статус каждую минуту
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateClosedState()
        }
    }

    // MARK: — Конфигурация подвидов + констрейнты

    private func configureImageView() {
        view.addSubview(imageView)
        imageView.pinTop(to: view.safeAreaLayoutGuide, 16)
        imageView.pinHorizontal(to: view, 16)
        imageView.setHeight(300)
        imageView.pinWidth(to: imageView.heightAnchor)
    }

    private func configureNameLabel() {
        view.addSubview(nameLabel)
        nameLabel.pinTop(to: imageView.bottomAnchor, 5)
        nameLabel.pinHorizontal(to: view, 16)
    }

    private func configureWeightLabel() {
        view.addSubview(weightLabel)
        weightLabel.pinTop(to: nameLabel.bottomAnchor, 4)
        weightLabel.pinHorizontal(to: view, 16)
    }

    private func configureDescriptionLabel() {
        view.addSubview(descriptionLabel)
        descriptionLabel.pinTop(to: weightLabel.bottomAnchor, 10)
        descriptionLabel.pinHorizontal(to: view, 16)
    }

    private func configureNutritionLabel() {
        view.addSubview(nutritionLabel)
        nutritionLabel.pinTop(to: descriptionLabel.bottomAnchor, 8)
        nutritionLabel.pinHorizontal(to: view, 16)
    }

    private func configureCompositionLabel() {
        view.addSubview(compositionLabel)
        compositionLabel.pinTop(to: nutritionLabel.bottomAnchor, 8)
        compositionLabel.pinHorizontal(to: view, 16)
    }

    private func configureCounterButton() {
        view.addSubview(counterButton)
        counterButton.pinHorizontal(to: view, 16)
        counterButton.setHeight(mode: .equal, 50)
        counterButton.pinBottom(to: view.safeAreaLayoutGuide, 16)
        
        counterButton.onIncrease = { [weak self] in
            guard let self = self, let meal = self.currentMeal else { return }
            CartService.shared.add(meal: meal)
        }
        
        counterButton.onDecrease = { [weak self] in
            guard let self = self, let meal = self.currentMeal else { return }
            CartService.shared.remove(meal: meal)
        }
    }

    // MARK: — Cart Observer
    @objc private func cartDidChange() {
        guard let meal = currentMeal else { return }
        let count = CartService.shared.getAllItems().first { $0.meal == meal }?.count ?? 0
        counterButton.updateCount(count)
    }

    // MARK: — DisplayLogic
    func displayMeal(viewModel: MealDetail.Load.ViewModel) {
        currentMeal = interactor?.meal
        
        nameLabel.text = viewModel.name
        weightLabel.text = viewModel.weightText
        descriptionLabel.text = viewModel.description
        nutritionLabel.text = """
            \(viewModel.kcalText)
            \(viewModel.proteinText)
            \(viewModel.fatText)
            \(viewModel.carbsText)
            """
        compositionLabel.text = "Состав: \(viewModel.composition)"
        
        if let meal = currentMeal {
            counterButton.configure(price: meal.price)
            let count = CartService.shared.getAllItems().first { $0.meal == meal }?.count ?? 0
            counterButton.updateCount(count)
        }

        if let url = URL(string: viewModel.imageURL) {
            Task { await imageView.loadImageAsync(from: url.absoluteString) }
        }
        
        updateClosedState()
    }
}
