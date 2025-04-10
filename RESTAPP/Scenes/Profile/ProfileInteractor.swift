//
//  ProfileInteractor.swift
//  RESTAPP
//
//  Created by Артём on 30.04.2025.
//

import FirebaseAuth
import Foundation
import UIKit

private struct CachedProfile: Codable {
    let orders : [Order]
    let savedAt: Date
}

// MARK: – Business and DataStore protocols

protocol ProfileBusinessLogic {
    func loadProfile(request: Profile.LoadProfile.Request)
    func logout(request: Profile.Logout.Request)
}

protocol ProfileDataStore {
    var userName : String? { get set }
    var userEmail: String? { get set }
}

// MARK: – Interactor

final class ProfileInteractor: ProfileBusinessLogic, ProfileDataStore {

    // MARK: – Dependencies

    var presenter: ProfilePresentationLogic?
    private let orderService: OrderService

    // MARK: – State

    var userName : String?
    var userEmail: String?

    // MARK: – Init

    init(orderService: OrderService) {
        self.orderService = orderService
    }

    // MARK: – Public API

    func loadProfile(request: Profile.LoadProfile.Request) {
        Task {
            await showCachedProfileIfNeeded()

            await fetchAndPresentProfile()
        }
    }

    func logout(request: Profile.Logout.Request) {
        do {
            try Auth.auth().signOut()

            ["userName", "userEmail", "isLoggedIn"].forEach {
                UserDefaults.standard.removeObject(forKey: $0)
            }

            try? FileManager.default.removeItem(at: cacheURL)

            presenter?.presentLogout(response: .init())
        } catch {
            print("Error signing out:", error)
        }
    }

    // MARK: – Private helpers
    private var cacheURL: URL {
        FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("profile.cache")
    }

    private let cacheTTL: TimeInterval = 60 * 5

    private func showCachedProfileIfNeeded() async {
        guard
            let data  = try? Data(contentsOf: cacheURL),
            let cache = try? JSONDecoder().decode(CachedProfile.self, from: data),
            Date().timeIntervalSince(cache.savedAt) < cacheTTL,
            let currentUser = Auth.auth().currentUser
        else { return }

        let resp = Profile.LoadProfile.Response(
            name:  currentUser.displayName ?? "Пользователь",
            email: currentUser.email       ?? "Нет email",
            orders: cache.orders
        )
        await MainActor.run {
            presenter?.presentProfile(response: resp)
        }
    }

    private func fetchAndPresentProfile() async {
        do {
            guard let currentUser = Auth.auth().currentUser else {
                throw NSError(domain: "RESTAPP",
                              code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "Неавторизован"])
            }

            let orders = try await orderService.fetchOrders(for: currentUser.uid)

            let cache = CachedProfile(orders: orders, savedAt: Date())
            if let data = try? JSONEncoder().encode(cache) {
                try? data.write(to: cacheURL, options: .atomic)
            }
            let name  = currentUser.displayName
                ?? UserDefaults.standard.string(forKey: "userName")
                ?? "Пользователь"
            let email = currentUser.email
                ?? UserDefaults.standard.string(forKey: "userEmail")
                ?? "Нет email"

            let resp = Profile.LoadProfile.Response(
                name:   name,
                email:  email,
                orders: orders
            )
            await MainActor.run {
                presenter?.presentProfile(response: resp)
            }

        } catch {
            print("Profile loading failed:", error)
        }
    }
}
