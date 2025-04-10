//
//  MainRouter.swift
//  RESTAPP
//
//  Created by Артём on 29.03.2025.
//
import UIKit

// MARK: – Protocols
protocol MainRoutingLogic {
    func routeToMealDetail(meal: Meal)
    func routeToProfile()
    func routeToCart()
}
protocol MainDataPassing { }

// MARK: – Router
final class MainRouter: NSObject, MainRoutingLogic, MainDataPassing {

    weak var viewController: UIViewController?

    func routeToMealDetail(meal: Meal) {
        let detailVC = MealDetailAssembly.build(with: meal)

        if let sheet = detailVC.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.large()]
            }
            sheet.prefersGrabberVisible = true
        }
        viewController?.present(detailVC, animated: true)
    }

    func routeToProfile() {
        let profileVC = ProfileAssembly.build()
        viewController?.navigationItem.backButtonTitle = "Назад"
        viewController?
            .navigationController?
            .pushViewController(profileVC, animated: true)
    }

    func routeToCart() {
        let cartVC = CartAssembly.build()
        cartVC.modalPresentationStyle = .pageSheet

        if let sheet = cartVC.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.large()]
            }
            sheet.prefersGrabberVisible = true
        }
        viewController?.present(cartVC, animated: true)
    }
}
