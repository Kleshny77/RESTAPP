//
//  CartModel.swift
//  RESTAPP
//
//  Created by Артём on 01.04.2025.
//

import UIKit

// MARK: - Cart Model

enum Cart {
    enum Load {
        struct Request {}
        
        struct Response {
            let items: [(meal: Meal, count: Int)]
            let total: Double
        }
        
        struct ViewModel {
            let items: [CartItemViewModel]
            let totalText: String
        }
    }
}

// MARK: - CartItemViewModel

struct CartItemViewModel {
    let name: String
    let countText: String
    let totalPriceText: String
}
