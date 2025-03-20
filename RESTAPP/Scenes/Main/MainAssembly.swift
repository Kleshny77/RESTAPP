//
//  MainAssembly.swift
//  RESTAPP
//
//  Created by Артём on 29.03.2025.
//

import UIKit

// MARK: - Assembly
enum MainAssembly {
    static func build() -> UIViewController {
        let interactor = MainInteractor()
        let presenter = MainPresenter()
        let router = MainRouter()
        let viewController = MainViewController(interactor: interactor, router: router)
        
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        
        return viewController
    }
}
