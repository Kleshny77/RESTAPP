//
//  CartViewInteractor.swift
//  RESTAPP
//
//  Created by Артём on 28.03.2025.
//

import UIKit

protocol CartBusinessLogic {
    func loadCart(request: Cart.Load.Request)
}

final class CartInteractor: CartBusinessLogic {
    var presenter: CartPresentationLogic?
    
    func loadCart(request: Cart.Load.Request) {
        let rawItems = CartService.shared.getAllItems()
        let items = rawItems.map { (meal: $0.meal, count: $0.count) }
        let total = CartService.shared.totalPrice

        let response = Cart.Load.Response(items: items, total: total)
        presenter?.presentCart(response: response)
    }
}
