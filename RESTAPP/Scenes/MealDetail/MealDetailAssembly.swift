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
        interactor.meal = meal
        
        let presenter  = MealDetailPresenter()
        interactor.presenter = presenter
        
        let viewController = MealDetailViewController()
        viewController.interactor = interactor
        presenter.viewController  = viewController
        
        return viewController
    }
}
