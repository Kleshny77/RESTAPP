//
//  OrderConfirmationViewController.swift
//  RESTAPP
//
//  Created by Артём on 03.04.2025.
//

import UIKit

protocol OrderConfirmationDisplayLogic: AnyObject {
    func displayOrderCompleted()
    func displayOrder(viewModel: OrderConfirmation.ShowOrder.ViewModel)
}

final class OrderConfirmationViewController: UIViewController {
    
    // MARK: - Dependencies
    private let interactor: OrderConfirmationBusinessLogic
    private let router: OrderConfirmationRoutingLogic
    
    // MARK: - Properties
    private var timer: Timer?
    private var remainingSeconds: Int = 600 // 10 минут
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let successImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 60)
        let image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
        let iv = UIImageView(image: image)
        iv.tintColor = .systemGreen
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Оплата прошла успешно!"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 36, weight: .bold)
        label.textAlignment = .center
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timerSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Заберите заказ"
        label.font = .systemFont(ofSize: 17)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let orderItemsLabel: UILabel = {
        let label = UILabel()
        label.text = "Ваш заказ"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let itemsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Заказ забран", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    init(interactor: OrderConfirmationBusinessLogic, router: OrderConfirmationRoutingLogic) {
        self.interactor = interactor
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startTimer()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        interactor.loadOrder(request: .init())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [successImageView, titleLabel, timerView, orderItemsLabel, itemsStackView].forEach {
            contentView.addSubview($0)
        }
        
        timerView.addSubview(timerLabel)
        timerView.addSubview(timerSubtitleLabel)
        
        view.addSubview(completeButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: completeButton.topAnchor, constant: -20),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            successImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            successImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: successImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            timerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            timerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            timerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            timerView.heightAnchor.constraint(equalToConstant: 120),
            
            timerLabel.centerXAnchor.constraint(equalTo: timerView.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: timerView.centerYAnchor, constant: -10),
            
            timerSubtitleLabel.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 4),
            timerSubtitleLabel.centerXAnchor.constraint(equalTo: timerView.centerXAnchor),
            
            orderItemsLabel.topAnchor.constraint(equalTo: timerView.bottomAnchor, constant: 32),
            orderItemsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            itemsStackView.topAnchor.constraint(equalTo: orderItemsLabel.bottomAnchor, constant: 16),
            itemsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            itemsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            itemsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completeButton.heightAnchor.constraint(equalToConstant: 54)
        ])
        
        updateTimerLabel()
    }
    
    // MARK: - Timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.remainingSeconds -= 1
            self.updateTimerLabel()
            
            if self.remainingSeconds <= 0 {
                self.timer?.invalidate()
                self.completeButtonTapped()
            }
        }
    }
    
    private func updateTimerLabel() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func createOrderItemView(title: String, quantity: Int, price: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 8
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16)
        
        let detailsLabel = UILabel()
        detailsLabel.text = "\(quantity) шт. · \(price) ₽"
        detailsLabel.font = .systemFont(ofSize: 14)
        detailsLabel.textColor = .secondaryLabel
        
        [titleLabel, detailsLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            
            detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            detailsLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            detailsLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            detailsLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        return container
    }
    
    // MARK: - Actions
    @objc private func completeButtonTapped() {
        interactor.completeOrder(request: .init())
    }
}

// MARK: - OrderConfirmationDisplayLogic
extension OrderConfirmationViewController: OrderConfirmationDisplayLogic {
    func displayOrderCompleted() {
        router.routeToMain()
    }
    
    func displayOrder(viewModel: OrderConfirmation.ShowOrder.ViewModel) {
        itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        viewModel.items.forEach { item in
            let itemView = createOrderItemView(
                title: item.name,
                quantity: item.quantity,
                price: item.price
            )
            itemsStackView.addArrangedSubview(itemView)
        }
    }
}
