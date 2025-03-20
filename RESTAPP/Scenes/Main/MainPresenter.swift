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
}

final class MainPresenter: MainPresentationLogic {
    weak var viewController: MainDisplayLogic?
    
    func presentFood(response: Main.LoadFood.Response) {
        let viewModel = Main.LoadFood.ViewModel(
            categories: response.categories.map { category in
                FoodCategoryViewModel(
                    title: category.name,
                    meals: category.meals.map { meal in
                        MealViewModel(
                            id: meal.id,
                            name: meal.name,
                            imageName: meal.imageURL,
                            priceText: "\(meal.price) ₽"
                        )
                    }
                )
            },
            domainCategories: response.categories
        )
        viewController?.displayFood(viewModel: viewModel)
    }
}
