//
//  CartService.swift
//  RESTAPP
//
//  Created by Артём on 27.03.2025.
//

import UIKit


final class CartService {

    static let shared = CartService()

    private var storage: [Meal: (count: Int, addedAt: Date)] = [:]

    func add(meal: Meal) {
        if let old = storage[meal] {
            let new = old.count + 1
            storage[meal] = (new, old.addedAt)
            notifyChange(meal: meal, count: new)
        } else {
            storage[meal] = (1, Date())
            notifyChange(meal: meal, count: 1)
        }
    }

    func remove(meal: Meal) {
        guard let old = storage[meal] else { return }
        let new = old.count - 1
        if new > 0 {
            storage[meal] = (new, old.addedAt)
        } else {
            storage.removeValue(forKey: meal)
        }
        notifyChange(meal: meal, count: max(new, 0))
    }

    func clear() {
            storage.removeAll()
            NotificationCenter.default.post(
                name: .cartDidChange,
                object: nil,
                userInfo: ["total": 0]
            )
        }

    func getAllItems() -> [(meal: Meal, count: Int, addedAt: Date)] {
        storage
            .map { ($0.key, $0.value.count, $0.value.addedAt) }
            .sorted { $0.addedAt < $1.addedAt }
    }

    var totalPrice: Int {
        storage.reduce(0) { $0 + Int($1.key.price) * $1.value.count }
    }
    
    private func notifyChange(meal: Meal, count: Int) {
        NotificationCenter.default.post(
            name: .cartDidChange,
            object: nil,
            userInfo: ["mealId": meal.id,
                       "newCount": count,
                       "total": totalPrice]
        )
    }
}
