//
//  CartAssembly.swift
//  RESTAPP
//
//  Created by Артём on 28.03.2025.
//

import UIKit

enum CartAssembly {
    static func build() -> UIViewController {
        let viewController = CartViewController()
        let interactor = CartInteractor()
        let presenter = CartPresenter()
        let router = CartRouter()
        
        viewController.interactor = interactor
        viewController.router = router
        
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        
        return viewController
    }
}
