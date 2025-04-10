//
//  CartPresenter.swift
//  RESTAPP
//
//  Created by Артём on 28.03.2025.
//

import Foundation

protocol CartPresentationLogic: AnyObject {
    func presentCart(response: Cart.Load.Response)
}

// MARK: CartPresenter.swift
final class CartPresenter: CartPresentationLogic {
    weak var viewController: CartDisplayLogic?
    
    func presentCart(response: Cart.Load.Response) {
        let items = response.items.map {
            CartItemViewModel(meal: $0.meal, count: $0.count)
        }
        let totalText = "Итого: \(response.total) ₽"
        viewController?.displayCart(
            viewModel: Cart.Load.ViewModel(items: items, totalText: totalText)
        )
    }
}
