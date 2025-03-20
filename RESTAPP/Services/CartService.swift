//
//  CartService.swift
//  RESTAPP
//
//  Created by Артём on 04.04.2025.
//

import UIKit

// MARK: - CartService

final class CartService {
    static let shared = CartService()
    
    private(set) var items: [Meal: Int] = [:]
    
    // MARK: - Public Methods
    
    func add(meal: Meal) {
        items[meal, default: 0] += 1
    }
    
    func remove(meal: Meal) {
        guard let count = items[meal], count > 1 else {
            items.removeValue(forKey: meal)
            return
        }
        items[meal] = count - 1
    }
    
    func clear() {
        items.removeAll()
    }
    
    func getAllItems() -> [(meal: Meal, count: Int)] {
        return items.map { ($0.key, $0.value) }
    }
    
    var totalPrice: Double {
        return items.reduce(0) { $0 + ($1.key.price * Double($1.value)) }
    }
}
