//
//  CartModel.swift
//  RESTAPP
//
//  Created by Артём on 28.03.2025.
//

import Foundation

enum Cart {
    enum Load {
        
        struct Request { }
        struct Response {
            let items : [(meal: Meal, count: Int)]
            let total : Int
        }
        
        struct ViewModel {
            let items    : [CartItemViewModel]
            let totalText: String
        }
    }
}

struct CartItemViewModel: Identifiable {
    let id        : String
    let meal      : Meal
    let imageURL  : String?
    let name      : String
    let weightText: String
    
    var count     : Int {
        didSet { priceText = "\(meal.price * count) ₽" }
    }
    var priceText : String
    
    init(meal: Meal, count: Int) {
        id          = meal.id
        self.meal   = meal
        name        = meal.name
        imageURL    = meal.imageURL
        weightText  = "\(meal.weight) г"
        self.count  = count
        priceText   = "\(meal.price * count) ₽"
    }
}
