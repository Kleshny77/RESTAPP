//
//  CartInteractor.swift
//  RESTAPP
//
//  Created by Артём on 01.04.2025.
//

import UIKit

// MARK: - CartBusinessLogic

protocol CartBusinessLogic {
    func loadCart(request: Cart.Load.Request)
}

// MARK: - CartInteractor

final class CartInteractor: CartBusinessLogic {
    
    // MARK: - Properties
    
    var presenter: CartPresentationLogic?
    
    // MARK: - Business Logic
    
    func loadCart(request: Cart.Load.Request) {
        let items = CartService.shared.getAllItems()
        let total = CartService.shared.totalPrice
        let response = Cart.Load.Response(items: items, total: total)
        presenter?.presentCart(response: response)
    }
}
