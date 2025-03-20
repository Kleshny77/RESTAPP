//
//  SignUpRouter.swift
//  RESTAPP
//
//  Created by Артём on 20.03.2025.
//

import UIKit

// MARK: - Routing Logic
@objc protocol SignUpRoutingLogic {
    func routeToMain()
}

// MARK: - Data Passing
protocol SignUpDataPassing {
    var dataStore: SignUpDataStore? { get }
}

final class SignUpRouter: NSObject, SignUpRoutingLogic, SignUpDataPassing {
    weak var viewController: UIViewController?
    var dataStore: SignUpDataStore?
    
    func routeToMain() {
        let mainVC = MainAssembly.build()
        let nav = UINavigationController(rootViewController: mainVC)
        nav.modalPresentationStyle = .fullScreen
        viewController?.present(nav, animated: true)
    }
}
