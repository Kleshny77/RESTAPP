//
//  SignUpInteraction.swift
//  RESTAPP
//
//  Created by Артём on 20.03.2025.
//

import UIKit
import FirebaseAuth

// MARK: - Business Logic
protocol SignUpBusinessLogic {
    func signUp(request: SignUp.Register.Request)
    func loadStaticContent()
}

// MARK: - Data Store
protocol SignUpDataStore { }

final class SignUpInteractor: SignUpBusinessLogic, SignUpDataStore {
    var presenter: SignUpPresentationLogic?
    
    func signUp(request: SignUp.Register.Request) {
        guard !request.fullName.isEmpty,
              !request.email.isEmpty,
              !request.password.isEmpty,
              !request.confirmPassword.isEmpty else {
            let response = SignUp.Register.Response(success: false, errorMessage: "Все поля обязательны")
            presenter?.presentSignUpResult(response: response)
            return
        }
        guard isValidEmail(request.email) else {
            let response = SignUp.Register.Response(success: false, errorMessage: "Введите корректный email")
            presenter?.presentSignUpResult(response: response)
            return
        }
        guard request.password == request.confirmPassword else {
            let response = SignUp.Register.Response(success: false, errorMessage: "Пароли не совпадают")
            presenter?.presentSignUpResult(response: response)
            return
        }
        
        Auth.auth().createUser(withEmail: request.email, password: request.password) { authResult, error in
            if let error = error {
                let response = SignUp.Register.Response(success: false, errorMessage: error.localizedDescription)
                self.presenter?.presentSignUpResult(response: response)
            } else {
                if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                    changeRequest.displayName = request.fullName
                    changeRequest.commitChanges { _ in }
                }
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(request.email, forKey: "userEmail")
                let response = SignUp.Register.Response(success: true, errorMessage: nil)
                self.presenter?.presentSignUpResult(response: response)
            }
        }
    }
    
    func loadStaticContent() {
        let response = SignUp.StaticContent.Response(
            title: "RESTAPP",
            description: "Create a new account",
            picture: UIImage(named: "image1") ?? UIImage()
        )
        presenter?.presentStaticContent(response: response)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
}
