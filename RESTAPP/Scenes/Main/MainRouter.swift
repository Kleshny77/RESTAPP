//
//  MainRouter.swift
//  RESTAPP
//
//  Created by Артём on 28.03.2025.
//

import UIKit

// MARK: - Routing Logic
protocol MainRoutingLogic {
    func routeToMealDetail(meal: Meal)
    func routeToProfile()
    func routeToCart()
}

// MARK: - Data Passing
protocol MainDataPassing { }

final class MainRouter: NSObject, MainRoutingLogic, MainDataPassing {
    weak var viewController: UIViewController?
    
    func routeToMealDetail(meal: Meal) {
        let detailVC = MealDetailViewController(meal: meal)
        if let sheet = detailVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        viewController?.present(detailVC, animated: true)
    }
    
    func routeToProfile() {
        let profileVC = ProfileAssembly.build()
        viewController?.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func routeToCart() {
        let cartVC = CartAssembly.build()
        if let sheet = cartVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        viewController?.present(cartVC, animated: true)
    }
}
