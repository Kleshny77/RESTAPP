//
//  MealDetailModels.swift
//  RESTAPP
//
//  Created by Артём on 02.04.2025.
//

import UIKit

// MARK: - MealDetail Models
enum MealDetail {
    enum Load {
        struct Request {
            let mealID: String
        }
        struct Response {
            let meal: Meal
        }
        struct ViewModel {
            let id: String
            let name: String
            let imageName: String
            let price: Int
            let priceText: String
            let weight: Int
            let weightText: String
            let description: String
        }
    }
}
