//
//  ProfilePresenter.swift
//  RESTAPP
//
//  Created by Артём on 30.04.2025.
//

import Foundation
import UIKit

protocol ProfilePresentationLogic {
    func presentProfile(response: Profile.LoadProfile.Response)
    func presentLogout(response: Profile.Logout.Response)
}

final class ProfilePresenter: ProfilePresentationLogic {
    
    weak var viewController: ProfileDisplayLogic?
    
    func presentProfile(response: Profile.LoadProfile.Response) {
        Task {
            let restaurantIds = Set(response.orders.map { $0.restaurantId })
            let mealIds       = Set(response.orders.flatMap { $0.items.map { $0.mealId } })
            
            async let restaurantsDictTask: [String: String] = {
                var dict: [String: String] = [:]
                for id in restaurantIds {
                    if let r = try? await RestaurantService.shared.fetchRestaurant(id: id) {
                        dict[id] = r.name
                    }
                }
                return dict
            }()
            
            async let mealsDictTask = MealService.shared.fetchMeals(ids: Array(mealIds))
            
            let restaurantNames = await restaurantsDictTask
            let mealsDict       = (try? await mealsDictTask) ?? [:]
            
            let orderVMs = response.orders.map { order -> OrderCellViewModel in
                let images: [URL] = order.items.compactMap {
                    guard let meal = mealsDict[$0.mealId],
                          let urlString = meal.imageURL,
                          let url = URL(string: urlString) else { return nil }
                    return url
                }
                return OrderCellViewModel(
                    order:          order,
                    restaurantName: restaurantNames[order.restaurantId] ?? "Столовая",
                    itemImageURLs:  images
                )
            }
            
            let vm = Profile.LoadProfile.ViewModel(
                name:   response.name,
                email:  response.email,
                orders: orderVMs
            )
            
            await MainActor.run {
                self.viewController?.displayProfile(viewModel: vm)
            }
        }
    }
    
    func presentLogout(response: Profile.Logout.Response) {
        viewController?.displayLogout(viewModel: .init())
    }
}
