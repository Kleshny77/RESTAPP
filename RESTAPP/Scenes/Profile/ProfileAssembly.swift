//
//  ProfileAssembly.swift
//  RESTAPP
//
//  Created by Артём on 10.04.2025.
//

import UIKit

enum ProfileAssembly {
  static func build() -> UIViewController {
    let orderService = OrderService.shared
    
    let router = ProfileRouter()
    let interactor = ProfileInteractor(orderService: orderService)
    let presenter = ProfilePresenter()
    let viewController = ProfileViewController(interactor: interactor, router: router)
    
    // Связываем компоненты
    interactor.presenter = presenter
    presenter.viewController = viewController
    router.viewController = viewController
    router.dataStore = interactor
    
    return viewController
  }
}
