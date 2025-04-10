//
//  MealDetailPresenter.swift
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
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        let kcalText = "Калории: \(meal.kcal) ккал"
        let proteinText = "Белки: \(meal.protein) г"
        let fatText = "Жиры: \(meal.fat) г"
        let carbsText = "Углеводы: \(meal.carbohydrates) г"
        
        let composition: String
        if let comp = meal.composition?.trimmingCharacters(in: .whitespacesAndNewlines),
           !comp.isEmpty {
            composition = comp
        } else {
            composition = "Состав не указан"
        }
        
        let priceText = "\(numberFormatter.string(from: NSNumber(value: meal.price)) ?? "\(meal.price)") ₽"
        let weightText = "\(numberFormatter.string(from: NSNumber(value: meal.weight)) ?? "\(meal.weight)") г"
        
        let vm = MealDetail.Load.ViewModel(
            id: meal.id,
            name: meal.name,
            imageURL: meal.imageURL ?? "",
            priceText: priceText,
            weightText: weightText,
            description: meal.description ?? "Описание отсутствует",
            kcalText: kcalText,
            proteinText: proteinText,
            fatText: fatText,
            carbsText: carbsText,
            composition: composition
        )
        
        viewController?.displayMeal(viewModel: vm)
    }
}
