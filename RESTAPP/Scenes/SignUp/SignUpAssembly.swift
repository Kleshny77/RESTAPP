//
//  SignUpAssembly.swift
//  RESTAPP
//
//  Created by Артём on 20.03.2025.
//

import UIKit

// MARK: - Assembly
enum SignUpAssembly {
    static func build() -> UIViewController {
        let interactor = SignUpInteractor()
        let presenter = SignUpPresenter()
        let router = SignUpRouter()
        let viewController = SignUpViewController(interactor: interactor, router: router)
        
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
        
        return viewController
    }
}
