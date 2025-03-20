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
}

final class MainInteractor: MainBusinessLogic {
    var presenter: MainPresentationLogic?
    
    func loadFood(request: Main.LoadFood.Request) {
        FirebaseService.shared.fetchCategories { [weak self] categories in
            let response = Main.LoadFood.Response(categories: categories)
            DispatchQueue.main.async {
                self?.presenter?.presentFood(response: response)
            }
        }
    }
}
