//
//  OrderConfirmationConfigurator.swift
//  RESTAPP
//
//  Created by Артём on 03.04.2025.
//

enum OrderConfirmationConfigurator {
    static func configure(orderId: String) -> OrderConfirmationViewController {
        let router = OrderConfirmationRouter()
        let presenter = OrderConfirmationPresenter()
        let interactor = OrderConfirmationInteractor(
            orderService: OrderService.shared,
            orderId: orderId
        )
        let viewController = OrderConfirmationViewController(
            interactor: interactor,
            router: router
        )
        
        presenter.viewController = viewController
        interactor.presenter = presenter
        router.viewController = viewController
        
        return viewController
    }
} 
