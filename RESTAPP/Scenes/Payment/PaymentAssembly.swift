//
//  PaymentAssembly.swift
//  RESTAPP
//
//  Created by Артём on 21.04.2025.
//


import UIKit

enum PaymentAssembly {
    static func build(amount: Int) -> UIViewController {
        let interactor = PaymentInteractor(amount: amount)
        let presenter  = PaymentPresenter()
        let router     = PaymentRouter()
        let vc         = PaymentViewController()

        interactor.presenter       = presenter
        interactor.router          = router
        presenter.viewController   = vc
        router.viewController      = vc

        vc.interactor = interactor
        vc.router     = router

        return vc
    }
}
