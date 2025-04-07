//
//  ProfileRouter.swift
//  RESTAPP
//
//  Created by Артём on 08.04.2025.
//

import UIKit

// MARK: - Profile Routing Logic

protocol ProfileRoutingLogic {
    func routeToAuth()
    func routeToEditProfile()
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
    
    func routeToEditProfile() {
//        guard let viewController = viewController else { return }
        
        // Создаем и настраиваем EditProfileViewController
//        let editProfileVC = UIViewController()
//        
//        // Если нужно передать данные в EditProfileViewController
//        if let userName = UserDefaults.standard.string(forKey: "userName") {
//            editProfileVC.configure(with: userName)
//        }
//        
//        // Показываем экран редактирования
//        viewController.navigationController?.pushViewController(editProfileVC, animated: true)
    }
}
