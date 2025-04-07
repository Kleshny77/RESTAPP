//
//  ProfileInteractor.swift
//  RESTAPP
//
//  Created by Артём on 03.04.2025.
//

import FirebaseAuth
import UIKit
import Foundation

// MARK: - Profile Business Logic

protocol ProfileBusinessLogic {
    func loadProfile(request: Profile.LoadProfile.Request)
    func logout(request: Profile.Logout.Request)
}

// MARK: - Profile Data Store

protocol ProfileDataStore {
    var userName: String? { get set }
    var userEmail: String? { get set }
}

// MARK: - Profile Interactor

final class ProfileInteractor: ProfileBusinessLogic, ProfileDataStore {
    var presenter: ProfilePresentationLogic?
    private let orderService: OrderService
    var userName: String?
    var userEmail: String?
    
    init(orderService: OrderService) {
        self.orderService = orderService
    }
    
    func loadProfile(request: Profile.LoadProfile.Request) {
        Task {
            do {
                guard let currentUser = Auth.auth().currentUser else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Неавторизован"])
                }
                
                let orders = try await orderService.fetchOrders(for: currentUser.uid)
                let name = currentUser.displayName ?? UserDefaults.standard.string(forKey: "userName") ?? "Пользователь"
                let email = currentUser.email ?? UserDefaults.standard.string(forKey: "userEmail") ?? "Нет email"
                
                self.userName = name
                self.userEmail = email
                
                let response = Profile.LoadProfile.Response(
                    name: name,
                    email: email,
                    orders: orders
                )
                
                await MainActor.run {
                    presenter?.presentProfile(response: response)
                }
            } catch {
                print("Error loading profile:", error)
                // можно сюда presenter?.presentError(...)
            }
        }
    }
    
    func logout(request: Profile.Logout.Request) {
        do {
            try Auth.auth().signOut()
            // Очищаем данные пользователя
            UserDefaults.standard.removeObject(forKey: "userName")
            UserDefaults.standard.removeObject(forKey: "userEmail")
            UserDefaults.standard.removeObject(forKey: "isLoggedIn")
            
            let response = Profile.Logout.Response()
            presenter?.presentLogout(response: response)
        } catch {
            print("Error signing out:", error)
            // Можно добавить обработку ошибки через presenter
        }
    }
}
