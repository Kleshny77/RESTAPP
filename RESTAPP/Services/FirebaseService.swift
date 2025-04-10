//
//  FirebaceService.swift
//  RESTAPP
//
//  Created by Артём on 27.03.2025.
//

import FirebaseFirestore
import UIKit

// MARK: - FirebaseService

final class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Restaurants
    
    func fetchRestaurants() async throws -> [Restaurant] {
        let snapshot = try await db.collection("restaurants").getDocuments()
        return snapshot.documents.compactMap { document in
            let data = document.data()
            guard let name = data["name"] as? String,
                  let openingHours = data["openingHours"] as? [String: [String: String?]]
            else { return nil }
            
            let schedule = Restaurant.OpeningHours(
                monday: parseSchedule(openingHours["monday"]),
                tuesday: parseSchedule(openingHours["tuesday"]),
                wednesday: parseSchedule(openingHours["wednesday"]),
                thursday: parseSchedule(openingHours["thursday"]),
                friday: parseSchedule(openingHours["friday"]),
                saturday: parseSchedule(openingHours["saturday"]),
                sunday: parseSchedule(openingHours["sunday"])
            )
            
            return Restaurant(
                id: document.documentID,
                name: name,
                openingHours: schedule
            )
        }
    }
    
    private func parseSchedule(_ data: [String: String?]?) -> Restaurant.OpeningHours.DaySchedule {
        guard let data = data else {
            return .init(open: nil, close: nil)
        }
        return .init(open: data["open"] ?? nil, close: data["close"] ?? nil)
    }
    
    func fetchRestaurant(id: String) async throws -> Restaurant {
        let document = try await db.collection("restaurants").document(id).getDocument()
        let data = document.data()
        
        guard
            let name = data?["name"] as? String,
            let openingHours = data?["openingHours"] as? [String: [String: String?]]
        else {
            throw NSError(
                domain: "AppError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid restaurant data for id \(id)"]
            )
        }
        
        let schedule = Restaurant.OpeningHours(
            monday: parseSchedule(openingHours["monday"]),
            tuesday: parseSchedule(openingHours["tuesday"]),
            wednesday: parseSchedule(openingHours["wednesday"]),
            thursday: parseSchedule(openingHours["thursday"]),
            friday: parseSchedule(openingHours["friday"]),
            saturday: parseSchedule(openingHours["saturday"]),
            sunday: parseSchedule(openingHours["sunday"])
        )
        
        return Restaurant(
            id: document.documentID,
            name: name,
            openingHours: schedule
        )
    }
    
    // MARK: - Categories
    
    func fetchCategories(completion: @escaping ([Category]) -> Void) {
        guard let currentRestaurant = RestaurantService.shared.currentRestaurant else {
            completion([])
            return
        }
        
        let restaurantRef = db.collection("restaurants").document(currentRestaurant.id)
        restaurantRef.collection("categories").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching categories: \(error)")
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
    
    private func processCategoryDocuments(_ documents: [QueryDocumentSnapshot], completion: @escaping ([Category]) -> Void) {
        var categories: [Category] = []
        let group = DispatchGroup()
        
        for document in documents {
            group.enter()
            let data = document.data()
            let catName = data["name"] as? String ?? "Без названия"
            let catID = document.documentID
            
            document.reference.collection("meals").getDocuments { [weak self] snapshot, error in
                defer { group.leave() }
                
                guard let self = self else { return }
                
                if let error = error {
                    print("Error loading meals for category \(catName): \(error)")
                    return
                }
                
                var meals: [Meal] = []
                if let documents = snapshot?.documents {
                    meals = documents.compactMap { self.parseMealDocument($0) }
                }
                
                let category = Category(id: catID, name: catName, meals: meals)
                categories.append(category)
            }
        }
        
        group.notify(queue: .main) {
            completion(categories.sorted { $0.name < $1.name })
        }
    }
    
    private func parseMealDocument(_ document: QueryDocumentSnapshot) -> Meal? {
        let data = document.data()
        
        guard let name = data["name"] as? String,
              let price = data["price"] as? Int,
              let weight = data["weight"] as? Int,
              let kcal = data["kcal"] as? Int,
              let protein = data["protein"] as? Int,
              let fat = data["fat"] as? Int,
              let carbohydrates = data["carbohydrates"] as? Int else {
            print("Error: Required fields are missing in meal document \(document.documentID)")
            return nil
        }
        
        let imageURL = data["imageURL"] as? String
        let description = data["description"] as? String
        let composition = data["composition"] as? String
        
        return Meal(
            id: document.documentID,
            name: name,
            price: price,
            weight: weight,
            kcal: kcal,
            protein: protein,
            fat: fat,
            carbohydrates: carbohydrates,
            imageURL: imageURL,
            description: description,
            composition: composition,
        )
    }
}
