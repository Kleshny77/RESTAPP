//
//  ProfileAssembly.swift
//  RESTAPP
//
//  Created by Артём on 10.04.2025.
//

import UIKit

enum ProfileAssembly {
    static func build() -> UIViewController {
        let interactor = ProfileInteractor()
        let presenter = ProfilePresenter()
        let router = ProfileRouter()

        let viewController = ProfileViewController(
            interactor: interactor,
            router: router
        )

        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController

        return viewController
    }
}
