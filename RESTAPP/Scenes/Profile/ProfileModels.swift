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
    let id: String
    let dateText: String
    let totalText: String
    let restaurantName: String
    let itemImageURLs: [URL]
    
    init(order: Order, restaurantName: String, itemImageURLs: [URL]) {
        self.id             = order.id
        self.restaurantName = restaurantName
        self.itemImageURLs  = Array(itemImageURLs.prefix(5))
        
        let df = DateFormatter()
        df.locale     = Locale(identifier: "ru_RU")
        df.dateFormat = "d MMMM 'в' HH:mm"
        self.dateText  = df.string(from: order.createdAt ?? Date())
        
        self.totalText = "\(order.total) ₽"
    }
}
