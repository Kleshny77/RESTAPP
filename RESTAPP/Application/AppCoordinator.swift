//
//  AppCoordinator.swift
//  RESTAPP
//
//  Created by Artem Samsonov on 12.02.2025.
//

import UIKit

class AppCoordinator {
    var window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func start() {
        let vc = RegistrationViewController() 
        let navController = UINavigationController(rootViewController: vc)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }
}
