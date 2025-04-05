//
//  PaymentViewController.swift
//  RESTAPP
//
//  Created by Артём on 21.04.2025.
//

import UIKit

protocol PaymentDisplayLogic: AnyObject {
    func displayPaymentResult(viewModel: Payment.MakePayment.ViewModel)
}

final class PaymentViewController: UIViewController, PaymentDisplayLogic {
    var interactor: PaymentBusinessLogic?
    var router: PaymentRoutingLogic?

    private let amountLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let payButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Оплатить", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        view.addSubview(amountLabel)
        view.addSubview(payButton)

        // подставим сумму из интерактора
        if let ds = interactor as? PaymentDataStore {
            amountLabel.text = "Сумма: \(ds.amount) ₽"
        }

        payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            amountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            amountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            payButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            payButton.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 20),
            payButton.heightAnchor.constraint(equalToConstant: 44),
            payButton.widthAnchor.constraint(equalToConstant: 200),
        ])
    }

    @objc private func payTapped() {
        guard let ds = interactor as? PaymentDataStore else { return }
        let req = Payment.MakePayment.Request(amount: ds.amount)
        interactor?.makePayment(request: req)
    }

    func displayPaymentResult(viewModel: Payment.MakePayment.ViewModel) {
        let alert = UIAlertController(
            title: viewModel.title,
            message: viewModel.message,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
