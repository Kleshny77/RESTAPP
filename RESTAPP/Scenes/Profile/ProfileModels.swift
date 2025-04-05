//
//  ProfileModels.swift
//  RESTAPP
//
//  Created by Артём on 03.04.2025.
//

import UIKit

// MARK: - Profile Models

enum Profile {
    enum LoadUser {
        struct Request {}
        struct Response {
            let name: String
        }
        struct ViewModel {
            let displayName: String
        }
    }
    
    enum LoadOrders {
        struct Request {}
        struct Response {
            let orders: [Order]
        }
        struct ViewModel {
            let orders: [OrderViewModel]
        }
    }
    
    enum Logout {
        struct Request {}
        struct Response {}
        struct ViewModel {}
    }
}

struct Order: Codable, Hashable {
    let id: String
    let date: Date
    let items: [String]
    let total: Int
}

struct OrderViewModel {
    let orderId: String
    let dateText: String
    let itemsText: String
    let totalText: String
}
