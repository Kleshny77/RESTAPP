//
//  ProfileRouter.swift
//  RESTAPP
//
//  Created by Артём on 30.03.2025.
//

import UIKit

// MARK: - Profile Routing Logic

protocol ProfileRoutingLogic {
    func routeToAuth()
}

protocol ProfileDataPassing {
    var dataStore: ProfileDataStore? { get }
}

// MARK: - Profile Router

final class ProfileRouter: ProfileRoutingLogic, ProfileDataPassing {
    weak var viewController: ProfileViewController?
    var dataStore: ProfileDataStore?
    
    // MARK: - Routing
    
    func routeToAuth() {
        if let window = viewController?.view.window {
            let authVC = LoginAssembly.build()
            let nav = UINavigationController(rootViewController: authVC)
            
            UIView.transition(with: window,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: {
                window.rootViewController = nav
            })
        }
    }
}
