//
//  Order.swift
//  RESTAPP
//
//  Created by Артём on 29.04.2025.
//

import Foundation

struct OrderItem: Codable, Hashable {
  let mealId: String
  let name: String
  let price: Int
  let quantity: Int
}

struct Order: Codable, Hashable {
  var id: String            // будет заполнено после записи
  let userId: String
  let restaurantId: String
  let createdAt: Date?
  let status: String
  let total: Int
  let items: [OrderItem]
}
