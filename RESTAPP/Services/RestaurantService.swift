//
//  RestaurantService.swift
//  RESTAPP
//
//  Created by Артём on 29.03.2025.
//

import Foundation
import FirebaseFirestore

final class RestaurantService {
    static let shared = RestaurantService()
    private let db = Firestore.firestore()
    
    @Published private(set) var currentRestaurant: Restaurant?
    
    private init() {}
    
    private var restaurantNames: [String: String] = [:]
    
    func fetchRestaurantName(id: String) async throws -> String {
        if let name = restaurantNames[id] {
            return name
        }
        
        let doc = try await db.collection("restaurants").document(id).getDocument()
        guard let data = doc.data(),
              let name = data["name"] as? String else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить название ресторана"])
        }
        
        restaurantNames[id] = name
        return name
    }
    
    func fetchRestaurantNames(ids: [String]) async throws -> [String: String] {
        var result: [String: String] = [:]
        
        let uncachedIds = ids.filter { !restaurantNames.keys.contains($0) }
        
        if !uncachedIds.isEmpty {
            let chunks = uncachedIds.chunked(into: 10)
            for chunk in chunks {
                let snapshot = try await db.collection("restaurants")
                    .whereField(FieldPath.documentID(), in: chunk)
                    .getDocuments()
                
                for doc in snapshot.documents {
                    if let name = doc.data()["name"] as? String {
                        restaurantNames[doc.documentID] = name
                    }
                }
            }
        }
        
        for id in ids {
            if let name = restaurantNames[id] {
                result[id] = name
            }
        }
        
        return result
    }
    
    func fetchRestaurants() async throws -> [Restaurant] {
        let snapshot = try await db.collection("restaurants").getDocuments()
        return snapshot.documents.compactMap { document in
            let data = document.data()
            
            guard
                let name = data["name"] as? String,
                let openingHours = data["openingHours"] as? [String: [String: String?]]
            else {
                print("Error: Invalid restaurant data for document \(document.documentID)")
                return nil
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
    }
    
    private func parseSchedule(_ data: [String: String?]?) -> Restaurant.OpeningHours.DaySchedule {
        guard let data = data else {
            return .init(open: nil, close: nil)
        }
        return .init(open: data["open"] ?? nil, close: data["close"] ?? nil)
    }
    
    func fetchRestaurant(id: String) async throws -> Restaurant {
        let doc = try await db.collection("restaurants").document(id).getDocument()
        let data = doc.data() ?? [:]
        
        guard
            let name = data["name"] as? String,
            let openingHours = data["openingHours"] as? [String: [String: String?]]
        else {
            throw NSError(domain: "", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid restaurant data"])
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
            id: doc.documentID,
            name: name,
            openingHours: schedule
        )
    }
    
    func setCurrentRestaurant(_ restaurant: Restaurant) {
        currentRestaurant = restaurant
        // Сохраняем выбор пользователя
        UserDefaults.standard.set(restaurant.id, forKey: "selectedRestaurantId")
    }
    
    func loadLastSelectedRestaurant() async throws {
        if let savedId = UserDefaults.standard.string(forKey: "selectedRestaurantId") {
            currentRestaurant = try await fetchRestaurant(id: savedId)
            return
        }
        
        let restaurants = try await fetchRestaurants()
        if let firstRestaurant = restaurants.first {
            currentRestaurant = firstRestaurant
            setCurrentRestaurant(firstRestaurant)
        }
    }
}

// MARK: - Helpers

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

