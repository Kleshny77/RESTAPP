//
//  LoginRouter.swift
//  RESTAPP
//
//  Created by Артём on 20.03.2025.
//

import UIKit

// MARK: - LoginRoutingLogic

@objc protocol LoginRoutingLogic {
    func routeToSignUp()
    func routeToMain()
}

// MARK: - LoginDataPassing

protocol LoginDataPassing {
    var dataStore: LoginDataStore? { get }
}

// MARK: - LoginRouter

final class LoginRouter: NSObject, LoginRoutingLogic, LoginDataPassing {
    weak var viewController: UIViewController?
    var dataStore: LoginDataStore?
    
    func routeToSignUp() {
        let signUpVC = SignUpAssembly.build()
        viewController?.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    func routeToMain() {
        let mainVC = MainAssembly.build()
        viewController?.navigationController?.setViewControllers([mainVC], animated: true)
    }
}
