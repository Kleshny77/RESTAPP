//
//  PaymentRouter.swift
//  RESTAPP
//
//  Created by Артём on 21.04.2025.
//

import UIKit

protocol PaymentRoutingLogic {
    func routeToConfirmation()
}

final class PaymentRouter: NSObject, PaymentRoutingLogic {
    weak var viewController: UIViewController?

    func routeToConfirmation() {
        let alert = UIAlertController(
            title: "Спасибо!",
            message: "Ваш заказ оплачен.",
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "OK", style: .default) { _ in
            self.viewController?.navigationController?.popViewController(animated: true)
        })
        viewController?.present(alert, animated: true)
    }
}
