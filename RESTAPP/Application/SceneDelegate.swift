//
//  SceneDelegate.swift
//  RESTAPP
//
//  Created by Artem Samsonov on 12.02.2025.
//

import UIKit
import Firebase
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Properties
    
    var window: UIWindow?
    
    // MARK: - UIScene Lifecycle
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        FirebaseApp.configure()
        
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        
        window?.rootViewController = createRootViewController()
        window?.makeKeyAndVisible()
    }
    
    // MARK: - Helper Methods
    
    private func createRootViewController() -> UIViewController {
        if UserDefaults.standard.bool(forKey: "isLoggedIn"),
           Auth.auth().currentUser != nil {
            let mainVC = MainAssembly.build()
            return UINavigationController(rootViewController: mainVC)
        } else {
            let loginVC = LoginAssembly.build()
            return UINavigationController(rootViewController: loginVC)
        }
    }
    
    // MARK: - SceneDelegate Methods
    
    func sceneDidDisconnect(_ scene: UIScene) {}
    
    func sceneDidBecomeActive(_ scene: UIScene) {}
    
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func sceneWillEnterForeground(_ scene: UIScene) {}
    
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
