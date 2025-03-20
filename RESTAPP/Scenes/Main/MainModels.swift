//
//  MainModels.swift
//  RESTAPP
//
//  Created by Артём on 28.03.2025.
//

import UIKit

// MARK: - Main Models
enum Main {
    enum LoadFood {
        struct Request {}
        struct Response {
            let categories: [FoodCategory]
        }
        struct ViewModel {
            let categories: [FoodCategoryViewModel]
            let domainCategories: [FoodCategory]
        }
    }
}

struct FoodCategory: Codable, Hashable {
    let id: String
    let name: String
    var meals: [Meal]
}

struct Meal: Codable, Hashable {
    let id: String
    let name: String
    let imageURL: String
    let price: Double
    let description: String
    let weight: Int
}

struct FoodCategoryViewModel {
    let title: String
    let meals: [MealViewModel]
}

struct MealViewModel {
    let id: String
    let name: String
    let imageName: String
    let priceText: String
}
