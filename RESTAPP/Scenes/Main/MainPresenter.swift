//
//  MainPresenter.swift
//  RESTAPP
//
//  Created by Артём on 28.03.2025.
//

import UIKit

// MARK: - Presentation Logic
protocol MainPresentationLogic {
    func presentFood(response: Main.LoadFood.Response)
    func presentRestaurants(response: Main.LoadRestaurants.Response)
    func presentSelectedRestaurant(response: Main.SelectRestaurant.Response)
}

final class MainPresenter: MainPresentationLogic {
    weak var viewController: MainDisplayLogic?
    
    func presentFood(response: Main.LoadFood.Response) {
        let viewModels = response.categories.map { category in
            Main.LoadFood.ViewModel.CategoryViewModel(
                title: category.name,
                meals: category.meals.map { MealViewModel(meal: $0) }
            )
        }
        
        let viewModel = Main.LoadFood.ViewModel(
            categories: viewModels,
            domainCategories: response.categories
        )
        viewController?.displayFood(viewModel: viewModel)
    }
    
    func presentRestaurants(response: Main.LoadRestaurants.Response) {
        let viewModel = Main.LoadRestaurants.ViewModel(
            restaurants: response.restaurants,
            selectedRestaurantId: response.selectedRestaurant?.id
        )
        viewController?.displayRestaurants(viewModel: viewModel)
    }
    
    func presentSelectedRestaurant(response: Main.SelectRestaurant.Response) {
        let viewModel = Main.SelectRestaurant.ViewModel(
            name: response.selectedRestaurant.name,
            workingHours: response.selectedRestaurant.openingHours.currentDaySchedule
        )
        viewController?.displaySelectedRestaurant(viewModel: viewModel)
    }
}
