//
//  FirebaseService.swift
//  RESTAPP
//
//  Created by Артём on 04.04.2025.
//

import FirebaseFirestore
import UIKit

// MARK: - FirebaseService

final class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    // MARK: - Public Methods
    
    func fetchCategories(completion: @escaping ([FoodCategory]) -> Void) {
        db.collection("categories").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Ошибка получения категорий: \(error.localizedDescription)")
                completion([])
                return
            }
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }
            self.processCategoryDocuments(documents, completion: completion)
        }
    }
    
    // MARK: - Private Methods
    
    private func processCategoryDocuments(_ documents: [QueryDocumentSnapshot], completion: @escaping ([FoodCategory]) -> Void) {
        var categories: [FoodCategory] = []
        let group = DispatchGroup()
        for document in documents {
            group.enter()
            let data = document.data()
            let catName = data["name"] as? String ?? "Без названия"
            let catID = document.documentID
            var category = FoodCategory(id: catID, name: catName, meals: [])
            
            document.reference.collection("meals").getDocuments { [weak self] snapshot, error in
                guard let self = self else {
                    group.leave()
                    return
                }
                if let error = error {
                    print("Ошибка загрузки блюд для категории \(catName): \(error.localizedDescription)")
                    group.leave()
                    return
                }
                var meals: [Meal] = []
                for mealDoc in snapshot?.documents ?? [] {
                    if let meal = self.parseMealDocument(mealDoc) {
                        meals.append(meal)
                    }
                }
                category.meals = meals
                categories.append(category)
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(categories)
        }
    }
    
    private func parseMealDocument(_ document: QueryDocumentSnapshot) -> Meal? {
        let mealData = document.data()
        guard
            let mealId = mealData["id"] as? String,
            let mealName = mealData["name"] as? String,
            let mealImage = mealData["imageURL"] as? String,
            let mealPrice = mealData["price"] as? Int,
            let mealDesc = mealData["description"] as? String,
            let mealWeight = mealData["weight"] as? Int
        else {
            print("Неверная структура документа \(document.documentID)")
            return nil
        }
        return Meal(
            id: mealId,
            name: mealName,
            imageURL: mealImage,
            price: mealPrice,
            description: mealDesc,
            weight: mealWeight
        )
    }
}
