//
//  CartService.swift
//  RESTAPP
//
//  Created by Артём on 04.04.2025.
//

import UIKit

// MARK: - CartService

// CartService.swift
final class CartService {

    static let shared = CartService()

    /// хранит: блюдо → (count, addedAt)
    private var storage: [Meal: (count: Int, addedAt: Date)] = [:]

    // MARK: – Public API -------------------------------------------------

    /// +1 к количеству / или добавляем новое со временем «сейчас»
    func add(meal: Meal) {
        if let tuple = storage[meal] {
            storage[meal] = (tuple.count + 1, tuple.addedAt)
        } else {
            storage[meal] = (1, Date())
        }
        notifyChange()
    }

    /// −1; если стало 0 – удаляем совсем
    func remove(meal: Meal) {
        guard let tuple = storage[meal] else { return }

        let newCount = tuple.count - 1
        if newCount > 0 {
            storage[meal] = (newCount, tuple.addedAt)
        } else {
            storage.removeValue(forKey: meal)
        }
        notifyChange()
    }

    func clear() { storage.removeAll() }

    /// ***Гарантированный порядок: старые → новые***
    func getAllItems() -> [(meal: Meal, count: Int, addedAt: Date)] {
        storage
            .map { ($0.key, $0.value.count, $0.value.addedAt) }
            .sorted { $0.addedAt < $1.addedAt }
    }

    var totalPrice: Int {
        storage.reduce(0) { $0 + Int($1.key.price) * $1.value.count }
    }
    
    private func notifyChange() {
        NotificationCenter.default.post(
            name: .cartDidChange,
            object: nil
        )
    }
}

