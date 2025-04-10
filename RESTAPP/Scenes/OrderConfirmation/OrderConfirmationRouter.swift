//
//  OrderConfirmationRouter.swift
//  RESTAPP
//
//  Created by Артём on 03.04.2025.
//

import UIKit

protocol OrderConfirmationRoutingLogic {
    func routeToMain()
}

final class OrderConfirmationRouter: NSObject, OrderConfirmationRoutingLogic {
    weak var viewController: OrderConfirmationViewController?
    
    func routeToMain() {
        viewController?.navigationController?.setViewControllers([MainAssembly.build()], animated: true)
    }
} 
