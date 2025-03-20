//
//  ProfilePresenter.swift
//  RESTAPP
//
//  Created by Артём on 03.04.2025.
//

import UIKit

// MARK: - Profile Presentation Logic

protocol ProfilePresentationLogic {
    func presentUser(response: Profile.LoadUser.Response)
    func presentOrders(response: Profile.LoadOrders.Response)
    func presentLogout(response: Profile.Logout.Response)
}

// MARK: - Profile Presenter

final class ProfilePresenter: ProfilePresentationLogic {
    weak var viewController: ProfileDisplayLogic?
    
    func presentUser(response: Profile.LoadUser.Response) {
        let viewModel = Profile.LoadUser.ViewModel(displayName: response.name)
        viewController?.displayUser(viewModel: viewModel)
    }
    
    func presentOrders(response: Profile.LoadOrders.Response) {
        let ordersVM = response.orders.map { order in
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            let dateText = formatter.string(from: order.date)
            let itemsText = order.items.joined(separator: ", ")
            let totalText = "\(order.total) ₽"
            return OrderViewModel(orderId: order.id, dateText: dateText, itemsText: itemsText, totalText: totalText)
        }
        let viewModel = Profile.LoadOrders.ViewModel(orders: ordersVM)
        viewController?.displayOrders(viewModel: viewModel)
    }
    
    func presentLogout(response: Profile.Logout.Response) {
        viewController?.displayLogout()
    }
}
