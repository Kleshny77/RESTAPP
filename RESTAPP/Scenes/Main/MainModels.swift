//
//  MainModels.swift
//  RESTAPP
//
//  Created by Артём on 28.03.2025.
//

import UIKit

// MARK: - Main Models
enum Main {
    // MARK: - Load Food
    enum LoadFood {
        struct Request {}
        
        struct Response {
            let categories: [Category]
        }
        
        struct ViewModel {
            let categories: [CategoryViewModel]
            let domainCategories: [Category]
            
            struct CategoryViewModel {
                let title: String
                let meals: [MealViewModel]
            }
        }
    }
    
    // MARK: - Load Restaurants
    enum LoadRestaurants {
        struct Request {}
        
        struct Response {
            let restaurants: [Restaurant]
            let selectedRestaurant: Restaurant?
        }
        
        struct ViewModel {
            let restaurants: [Restaurant]
            let selectedRestaurantId: String?
        }
    }
    
    // MARK: - Select Restaurant
    enum SelectRestaurant {
        struct Request {
            let restaurantId: String
        }
        
        struct Response {
            let selectedRestaurant: Restaurant
        }
        
        struct ViewModel {
            let name: String
            let workingHours: String?
        }
    }
}

struct FoodCategory: Codable, Hashable {
    let id: String
    let name: String
    var meals: [Meal]
}

struct FoodCategoryViewModel {
    let title: String
    let meals: [MealViewModel]
}

// MARK: - View Models
struct MealViewModel {
    let id: String
    let name: String
    let imageURL: String?
    let price: String
    let description: String?
    let weight: String
    let nutritionInfo: String
    
    init(meal: Meal) {
        self.id = meal.id
        self.name = meal.name
        self.imageURL = meal.imageURL
        self.price = "\(meal.price) ₽"
        self.description = meal.description
        self.weight = "\(meal.weight) г"
        self.nutritionInfo = "\(meal.kcal) ккал • Б: \(meal.protein) • Ж: \(meal.fat) • У: \(meal.carbohydrates)"
    }
}
