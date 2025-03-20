//
//  CartPresenter.swift
//  RESTAPP
//
//  Created by Артём on 01.04.2025.
//

import UIKit

// MARK: - CartPresentationLogic

protocol CartPresentationLogic {
    func presentCart(response: Cart.Load.Response)
}

// MARK: - CartPresenter

final class CartPresenter: CartPresentationLogic {
    
    // MARK: - Properties
    
    weak var viewController: CartDisplayLogic?
    
    // MARK: - Presentation Logic
    
    func presentCart(response: Cart.Load.Response) {
        let items = response.items.map {
            CartItemViewModel(
                name: $0.meal.name,
                countText: "x\($0.count)",
                totalPriceText: "\($0.meal.price * Double($0.count)) ₽"
            )
        }
        let totalText = "Итого: \(Int(response.total)) ₽"
        let viewModel = Cart.Load.ViewModel(items: items, totalText: totalText)
        viewController?.displayCart(viewModel: viewModel)
    }
}
