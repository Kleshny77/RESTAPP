//
//  Order.swift
//  RESTAPP
//
//  Created by Artem Samsonov on 03.02.2025.
//


import Foundation

struct OrderItem: Codable, Hashable {
    let mealId: String
    let name: String
    let price: Int
    let quantity: Int
}

struct Order: Codable, Hashable {
    var id: String         
    let userId: String
    let restaurantId: String
    let createdAt: Date?
    let status: String
    let total: Int
    let items: [OrderItem]
}
