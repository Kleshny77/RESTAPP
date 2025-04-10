//
//  ProfileAssembly.swift
//  RESTAPP
//
//  Created by Артём on 30.04.2025.
//

import UIKit

enum ProfileAssembly {
    static func build() -> UIViewController {
        let orderService = OrderService.shared
        let interactor   = ProfileInteractor(orderService: orderService)
        let presenter    = ProfilePresenter()
        let router       = ProfileRouter()
        let vc           = ProfileViewController(interactor: interactor, router: router)
        
        interactor.presenter    = presenter
        presenter.viewController = vc
        router.viewController   = vc
        router.dataStore        = interactor
        
        return vc
    }
}
