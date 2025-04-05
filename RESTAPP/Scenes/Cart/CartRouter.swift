//
//  CartRouter.swift
//  RESTAPP
//
//  Created by Артём on 01.04.2025.
//

import UIKit

// MARK: - CartRoutingLogic

protocol CartRoutingLogic {
    func routeToMealDetail(meal: Meal)
    func routeToPayment(total: Int)
}

// MARK: - CartDataPassing

protocol CartDataPassing {}

// MARK: - CartRouter

final class CartRouter: NSObject, CartRoutingLogic, CartDataPassing {
    
    // MARK: - Properties
    
    weak var viewController: UIViewController?
    
    func routeToMealDetail(meal: Meal) {
        let vc = MealDetailAssembly.build(with: meal)
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        viewController?.present(vc, animated: true)
    }
    
    func routeToPayment(total: Int) {
            // собираем модуль оплаты через моковый эквайринг
            let paymentVC = PaymentAssembly.build(amount: total)
            // например, пушим в навигацию
            if let nav = viewController?.navigationController {
                nav.pushViewController(paymentVC, animated: true)
            } else {
                viewController?.present(paymentVC, animated: true)
            }
        }
}
