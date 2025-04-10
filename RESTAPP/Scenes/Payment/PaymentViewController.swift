//
//  PaymentViewController.swift
//  RESTAPP
//
//  Created by Артём on 01.04.2025.
//


import UIKit
import FirebaseAuth

protocol PaymentDisplayLogic: AnyObject {
    func displayPaymentResult(viewModel: Payment.MakePayment.ViewModel)
}

final class PaymentViewController:
    UIViewController,
    PaymentDisplayLogic
{
    var interactor: (PaymentBusinessLogic & PaymentDataStore)?
    var router: PaymentRoutingLogic?
    
    // MARK: - UI Elements
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Сумма к оплате"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let payButton: UIButton = {
        let symbolCfg = UIImage.SymbolConfiguration(
            pointSize: 18,
            weight: .semibold
        )
        
        var cfg = UIButton.Configuration.filled()
        cfg.title = "Оплатить заказ"
        cfg.image = UIImage(systemName: "creditcard.fill")?.withConfiguration(symbolCfg)
        cfg.imagePadding = 8
        cfg.baseBackgroundColor = .systemGreen
        cfg.cornerStyle = .medium
        
        let payButton = UIButton(configuration: cfg)
        payButton.tintColor = .white
        payButton.translatesAutoresizingMaskIntoConstraints = false
        return payButton
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Оплата"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(amountLabel)
        view.addSubview(payButton)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            containerView.heightAnchor.constraint(equalToConstant: 160),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            amountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            amountLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            amountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            payButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            payButton.heightAnchor.constraint(equalToConstant: 54)
        ])
        
        if let ds = interactor {
            amountLabel.text = "\(ds.amount) ₽"
        }
        
        payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
    }
    
    @objc private func payTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.payButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.payButton.transform = .identity
            }
        }
        
        guard
            let userId = Auth.auth().currentUser?.uid,
            let ds = interactor
        else { return }
        
        payButton.isEnabled = false
        
        let req = Payment.MakePayment.Request(
            userId:       userId,
            restaurantId: ds.restaurantId,
            items:        ds.items
        )
        interactor?.makePayment(request: req)
    }
    
    func displayPaymentResult(viewModel: Payment.MakePayment.ViewModel) {
        payButton.isEnabled = true
        
        if !viewModel.title.contains("Успех") {
            let alert = UIAlertController(
                title: viewModel.title,
                message: viewModel.message,
                preferredStyle: .alert
            )
            alert.addAction(.init(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
