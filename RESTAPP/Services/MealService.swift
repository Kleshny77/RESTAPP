//
//  MealService.swift
//  RESTAPP
//
//  Created by Артём on 27.03.2025.
//

import FirebaseFirestore

final class MealService {
    static let shared = MealService()
    private let db = Firestore.firestore()
    private init() {}
    
    private var mealsCache: [String: Meal] = [:]
    
    func fetchMeal(id: String) async throws -> Meal {
        if let meal = mealsCache[id] {
            return meal
        }
        
        let categoriesSnapshot = try await db.collection("categories").getDocuments()
        
        for categoryDoc in categoriesSnapshot.documents {
            let mealDoc = try await categoryDoc.reference.collection("meals").document(id).getDocument()
            
            if mealDoc.exists, let meal = parseMealDocument(mealDoc) {
                mealsCache[id] = meal
                return meal
            }
        }
        
        throw NSError(
            domain: "MealService",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Блюдо не найдено"]
        )
    }
    
    func fetchMeals(ids: [String]) async throws -> [String: Meal] {
        var result: [String: Meal] = [:]
        
        let uncachedIds = ids.filter { !mealsCache.keys.contains($0) }
        
        if !uncachedIds.isEmpty {
            let categoriesSnapshot = try await db.collection("categories").getDocuments()
            
            for categoryDoc in categoriesSnapshot.documents {
                let remainingIds = uncachedIds.filter { !result.keys.contains($0) }
                if remainingIds.isEmpty { break }
                
                let mealsSnapshot = try await categoryDoc.reference.collection("meals")
                    .whereField(FieldPath.documentID(), in: remainingIds)
                    .getDocuments()
                
                for doc in mealsSnapshot.documents {
                    if let meal = parseMealDocument(doc) {
                        mealsCache[doc.documentID] = meal
                        result[doc.documentID] = meal
                    }
                }
            }
        }
        
        for id in ids {
            if let meal = mealsCache[id] {
                result[id] = meal
            }
        }
        
        return result
    }
    
    private func parseMealDocument(_ doc: DocumentSnapshot) -> Meal? {
        guard let data = doc.data() else { return nil }
        
        guard let name = data["name"] as? String,
              let price = data["price"] as? Int,
              let weight = data["weight"] as? Int,
              let kcal = data["kcal"] as? Int,
              let protein = data["protein"] as? Int,
              let fat = data["fat"] as? Int,
              let carbohydrates = data["carbohydrates"] as? Int else {
            return nil
        }
        
        let imageURL = data["imageURL"] as? String
        let description = data["description"] as? String
        
        return Meal(
            id: doc.documentID,
            name: name,
            price: price,
            weight: weight,
            kcal: kcal,
            protein: protein,
            fat: fat,
            carbohydrates: carbohydrates,
            imageURL: imageURL,
            description: description
        )
    }
}

