//
//  MainInteractor.swift
//  RESTAPP
//
//  Created by Артём on 28.03.2025.
//

import UIKit

// MARK: - Business Logic
protocol MainBusinessLogic {
    func loadFood(request: Main.LoadFood.Request)
    func loadRestaurants(request: Main.LoadRestaurants.Request)
    func selectRestaurant(request: Main.SelectRestaurant.Request)
}

final class MainInteractor: MainBusinessLogic {
    var presenter: MainPresentationLogic?
    private let restaurantService = RestaurantService.shared
    private let firebaseService = FirebaseService.shared
    
    func loadFood(request: Main.LoadFood.Request) {
        guard restaurantService.currentRestaurant != nil else { return }
        
        firebaseService.fetchCategories { [weak self] categories in
            let response = Main.LoadFood.Response(categories: categories)
            DispatchQueue.main.async {
                self?.presenter?.presentFood(response: response)
            }
        }
    }
    
    func loadRestaurants(request: Main.LoadRestaurants.Request) {
        Task {
            do {
                let restaurants = try await firebaseService.fetchRestaurants()
                let currentRestaurant = restaurantService.currentRestaurant
                let response = Main.LoadRestaurants.Response(
                    restaurants: restaurants,
                    selectedRestaurant: currentRestaurant
                )
                await MainActor.run {
                    presenter?.presentRestaurants(response: response)
                }
            } catch {
                print("Error loading restaurants: \(error)")
            }
        }
    }
    
    func selectRestaurant(request: Main.SelectRestaurant.Request) {
        Task {
            do {
                let restaurants = try await firebaseService.fetchRestaurants()
                if let restaurant = restaurants.first(where: { $0.id == request.restaurantId }) {
                    
                    CartService.shared.clear()
                    restaurantService.setCurrentRestaurant(restaurant)
                    
                    let response = Main.SelectRestaurant.Response(selectedRestaurant: restaurant)
                    await MainActor.run {
                        presenter?.presentSelectedRestaurant(response: response)
                        loadFood(request: .init())
                    }
                }
            } catch {
                print("Error selecting restaurant: \(error)")
            }
        }
    }
}
