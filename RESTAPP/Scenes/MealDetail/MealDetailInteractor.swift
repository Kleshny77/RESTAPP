//
//  MealDetailInteractor.swift
//  RESTAPP
//
//  Created by Артём on 02.04.2025.
//

import UIKit

// MARK: - Business Logic
protocol MealDetailBusinessLogic {
    func loadMeal(request: MealDetail.Load.Request)
}

// MARK: - Data Store
protocol MealDetailDataStore {
    var meal: Meal? { get set }
}

final class MealDetailInteractor: MealDetailBusinessLogic, MealDetailDataStore {
    var presenter: MealDetailPresentationLogic?
    var meal: Meal?
    
    func loadMeal(request: MealDetail.Load.Request) {
        guard let meal = meal else { return }
        presenter?.presentMeal(response: .init(meal: meal))
    }
}
