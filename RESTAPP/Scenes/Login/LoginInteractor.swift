//
//  LoginInteractor.swift
//  RESTAPP
//
//  Created by Артём on 20.03.2025.
//

import UIKit
import FirebaseAuth

// MARK: - LoginBusinessLogic

protocol LoginBusinessLogic {
    func login(request: Login.Authenticate.Request)
    func loadStaticContent()
}

// MARK: - LoginDataStore

protocol LoginDataStore {
    var userEmail: String? { get set }
}

// MARK: - LoginInteractor

final class LoginInteractor: LoginBusinessLogic, LoginDataStore {
    var presenter: LoginPresentationLogic?
    var userEmail: String?
    
    func login(request: Login.Authenticate.Request) {
        Auth.auth().signIn(withEmail: request.email, password: request.password) { authResult, error in
            if let error = error {
                let response = Login.Authenticate.Response(success: false, errorMessage: error.localizedDescription)
                self.presenter?.presentLoginResult(response: response)
            } else {
                self.userEmail = request.email
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(request.email, forKey: "userEmail")
                let response = Login.Authenticate.Response(success: true, errorMessage: nil)
                self.presenter?.presentLoginResult(response: response)
            }
        }
    }
    
    func loadStaticContent() {
        let response = Login.StaticContent.Response(
            title: "RESTAPP",
            description: "Sign in to your account",
            picture: UIImage(named: "image1") ?? UIImage()
        )
        presenter?.presentStaticContent(response: response)
    }
}
