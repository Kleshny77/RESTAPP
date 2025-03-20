//
//  LoginAssembly.swift
//  RESTAPP
//
//  Created by Артём on 20.03.2025.
//

import UIKit

// MARK: - Login Assembly

enum LoginAssembly {
    static func build() -> UIViewController {
        let interactor = LoginInteractor()
        let presenter = LoginPresenter()
        let router = LoginRouter()
        let viewController = LoginViewController(interactor: interactor, router: router)
        
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.dataStore = interactor
        router.viewController = viewController
        
        return viewController
    }
}
