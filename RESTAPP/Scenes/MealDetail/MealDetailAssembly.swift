//
//  MealDetailAssembly.swift
//  RESTAPP
//
//  Created by Артём on 02.04.2025.
//

import UIKit

// MARK: - Assembly
enum MealDetailAssembly {
    static func build(with meal: Meal) -> UIViewController {
        let interactor = MealDetailInteractor()
        let presenter = MealDetailPresenter()
        let viewController = MealDetailViewController(meal: meal)
        
        interactor.presenter = presenter
        presenter.viewController = viewController
        viewController.interactor = interactor
        
        return viewController
    }
}
