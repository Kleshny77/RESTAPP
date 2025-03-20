//
//  ProfileInteractor.swift
//  RESTAPP
//
//  Created by Артём on 03.04.2025.
//

import FirebaseAuth
import UIKit

// MARK: - Profile Business Logic

protocol ProfileBusinessLogic {
    func loadUser(request: Profile.LoadUser.Request)
    func loadOrders(request: Profile.LoadOrders.Request)
    func logout(request: Profile.Logout.Request)
}

// MARK: - Profile Interactor

final class ProfileInteractor: ProfileBusinessLogic {
    var presenter: ProfilePresentationLogic?
    
    func loadUser(request: Profile.LoadUser.Request) {
        let name = Auth.auth().currentUser?.displayName ?? "Без имени"
        presenter?.presentUser(response: .init(name: name))
    }
    
    func loadOrders(request: Profile.LoadOrders.Request) {
        let orders: [Order] = [
            Order(id: "1", date: Date(), items: ["Пельмени", "Борщ"], total: 330),
            Order(id: "2", date: Date(), items: ["Компот"], total: 60)
        ]
        presenter?.presentOrders(response: .init(orders: orders))
    }
    
    func logout(request: Profile.Logout.Request) {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            presenter?.presentLogout(response: .init())
        } catch {
            print(error.localizedDescription)
        }
    }
}
