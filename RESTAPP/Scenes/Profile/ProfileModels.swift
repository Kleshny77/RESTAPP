//
//  ProfileModels.swift
//  RESTAPP
//
//  Created by Артём on 03.04.2025.
//

import UIKit

// MARK: - Profile Models

enum Profile {
    // MARK: - Load Profile
    enum LoadProfile {
        struct Request {}
        
        struct Response {
            let name: String
            let email: String
            let orders: [Order]
        }
        
        struct ViewModel {
            let name: String
            let email: String
            let orders: [OrderCellViewModel]
        }
    }
    
    // MARK: - Logout
    enum Logout {
        struct Request {}
        struct Response {}
        struct ViewModel {}
    }
}

// MARK: - View Models
struct OrderCellViewModel {
  let id:    String
  let date:  String
  let items: String
  let total: String

  init(order: Order) {
    self.id = order.id
    // 1) форматируем дату
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    let d = order.createdAt ?? Date()
    self.date = dateFormatter.string(from: d)
    // 2) список названий блюд
    self.items = order.items.map { $0.name }.joined(separator: ", ")
    // 3) общая сумма
    self.total = "\(order.total) ₽"
  }
}
