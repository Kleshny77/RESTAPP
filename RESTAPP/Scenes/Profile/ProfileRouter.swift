//
//  ProfileRouter.swift
//  RESTAPP
//
//  Created by Артём on 08.04.2025.
//

import UIKit

// MARK: - Profile Routing Logic

protocol ProfileRoutingLogic {
    func routeToLogin()
}

// MARK: - Profile Router

final class ProfileRouter: ProfileRoutingLogic {
    weak var viewController: UIViewController?
    
    func routeToLogin() {
        let loginVC = LoginAssembly.build()
        let nav = UINavigationController(rootViewController: loginVC)
        nav.modalPresentationStyle = .fullScreen
        viewController?.present(nav, animated: true)
    }
}
