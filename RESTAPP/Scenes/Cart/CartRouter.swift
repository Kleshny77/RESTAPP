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
    func routeToPayment()
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
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        viewController?.present(vc, animated: true)
    }
    
    func routeToPayment() {
        let items: [OrderItem] = CartService.shared.getAllItems().map { entry in
            OrderItem(
                mealId:   entry.meal.id,
                name:     entry.meal.name,
                price:    entry.meal.price,
                quantity: entry.count
            )
        }
        guard let restaurantId = RestaurantService.shared.currentRestaurant?.id else {
            print("Не выбран ресторан")
            return
        }
        let paymentVC = PaymentAssembly.build(
            items: items,
            restaurantId: restaurantId
        )
        if let nav = viewController?.navigationController {
            nav.pushViewController(paymentVC, animated: true)
        } else {
            viewController?.present(paymentVC, animated: true)
        }
    }
}
