// PaymentViewController.swift

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

  private let amountLabel = UILabel()
  private let payButton   = UIButton(type: .system)

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    setupUI()
  }

  private func setupUI() {
    amountLabel.font = .systemFont(ofSize: 20, weight: .semibold)
    payButton.setTitle("Оплатить", for: .normal)
    payButton.titleLabel?.font = .systemFont(ofSize: 18)
    payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)

    [amountLabel, payButton].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview($0)
    }
    NSLayoutConstraint.activate([
      amountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      amountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

      payButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      payButton.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 20),
      payButton.heightAnchor.constraint(equalToConstant: 44),
      payButton.widthAnchor.constraint(equalToConstant: 200),
    ])

    if let ds = interactor {
      amountLabel.text = "Сумма: \(ds.amount) ₽"
    }
  }

  @objc private func payTapped() {
    guard
      let userId = Auth.auth().currentUser?.uid,
      let ds     = interactor
    else { return }

    let req = Payment.MakePayment.Request(
      userId:       userId,
      restaurantId: ds.restaurantId,
      items:        ds.items
    )
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
