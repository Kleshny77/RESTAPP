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
        
        // Форматируем числовые значения
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        // Форматируем строки с пищевой ценностью
        let kcalText = "Калории: \(meal.kcal) ккал"
        let proteinText = "Белки: \(meal.protein) г"
        let fatText = "Жиры: \(meal.fat) г"
        let carbsText = "Углеводы: \(meal.carbohydrates) г"
        
        // Определяем состав блюда
        let composition: String
        if let comp = meal.composition?.trimmingCharacters(in: .whitespacesAndNewlines),
           !comp.isEmpty {
            // если в БД пришёл непустой состав
            composition = comp
        } else {
            // иначе пишем дефолт
            composition = "Состав не указан"
        }
        
        // Форматируем цену и вес
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
