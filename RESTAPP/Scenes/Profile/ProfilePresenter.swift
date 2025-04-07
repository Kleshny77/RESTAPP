//
//  ProfilePresenter.swift
//  RESTAPP
//
//  Created by Артём on 03.04.2025.
//

import UIKit
import Foundation

// MARK: - Profile Presentation Logic

protocol ProfilePresentationLogic {
    func presentProfile(response: Profile.LoadProfile.Response)
    func presentLogout(response: Profile.Logout.Response)
}

// MARK: - Profile Presenter

final class ProfilePresenter: ProfilePresentationLogic {
    weak var viewController: ProfileDisplayLogic?
    
    func presentProfile(response: Profile.LoadProfile.Response) {
        let orderViewModels = response.orders.map { OrderCellViewModel(order: $0) }
        
        let viewModel = Profile.LoadProfile.ViewModel(
            name: response.name,
            email: response.email,
            orders: orderViewModels
        )
        
        viewController?.displayProfile(viewModel: viewModel)
    }
    
    func presentLogout(response: Profile.Logout.Response) {
        viewController?.displayLogout(viewModel: .init())
    }
}
