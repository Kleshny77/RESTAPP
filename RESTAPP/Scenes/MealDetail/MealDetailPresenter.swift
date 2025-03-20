//
//  MealDetailPresenter.swift.swift
//  RESTAPP
//
//  Created by Артём on 02.04.2025.
//

import UIKit

// MARK: - Presentation Logic
protocol MealDetailPresentationLogic {
    func presentMeal(response: MealDetail.Load.Response)
}

final class MealDetailPresenter: MealDetailPresentationLogic {
    weak var viewController: MealDetailDisplayLogic?
    
    func presentMeal(response: MealDetail.Load.Response) {
        let meal = response.meal
        let viewModel = MealDetail.Load.ViewModel(
            id: meal.id,
            name: meal.name,
            imageName: meal.imageURL,
            price: meal.price,
            priceText: "\(meal.price) ₽",
            weight: meal.weight,
            weightText: "\(meal.weight) г",
            description: meal.description
        )
        viewController?.displayMeal(viewModel: viewModel)
    }
}
