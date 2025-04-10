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
        struct Request {}
        struct Response {
            let meal: Meal
        }
        struct ViewModel {
            let id: String
            let name: String
            let imageURL: String
            let priceText: String
            let weightText: String
            let description: String
            let kcalText: String
            let proteinText: String
            let fatText: String
            let carbsText: String
            let composition: String
        }
    }
}
