//
//  PaymentRouter.swift
//  RESTAPP
//
//  Created by Артём on 01.04.2025.
//


import UIKit

protocol PaymentRoutingLogic {
    func routeToConfirmation(orderId: String)
}

final class PaymentRouter: NSObject, PaymentRoutingLogic {
    weak var viewController: UIViewController?
    
    func routeToConfirmation(orderId: String) {
        let confirmationVC = OrderConfirmationConfigurator.configure(orderId: orderId)
    
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootNav = window.rootViewController as? UINavigationController {
            
            rootNav.dismiss(animated: true) {
                rootNav.pushViewController(confirmationVC, animated: true)
            }
        }
    }
}
