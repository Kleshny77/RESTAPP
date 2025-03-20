//
//  SignUpPresenter.swift
//  RESTAPP
//
//  Created by Артём on 20.03.2025.
//

import UIKit

// MARK: - Presentation Logic
protocol SignUpPresentationLogic {
    func presentSignUpResult(response: SignUp.Register.Response)
    func presentStaticContent(response: SignUp.StaticContent.Response)
}

final class SignUpPresenter: SignUpPresentationLogic {
    weak var viewController: SignUpDisplayLogic?
    
    func presentSignUpResult(response: SignUp.Register.Response) {
        let viewModel = SignUp.Register.ViewModel(
            isSuccess: response.success,
            message: response.success ? "Регистрация прошла успешно" : (response.errorMessage ?? "Ошибка регистрации")
        )
        viewController?.displayRegistrationResult(viewModel)
    }
    
    func presentStaticContent(response: SignUp.StaticContent.Response) {
        let viewModel = SignUp.StaticContent.ViewModel(
            title: response.title,
            description: response.description,
            picture: response.picture
        )
        viewController?.displayStaticContent(viewModel: viewModel)
    }
}
