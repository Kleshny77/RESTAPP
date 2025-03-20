//
//  LoginPresenter.swift.swift
//  RESTAPP
//
//  Created by Артём on 20.03.2025.
//

import Foundation

// MARK: - LoginPresentationLogic

protocol LoginPresentationLogic {
    func presentLoginResult(response: Login.Authenticate.Response)
    func presentStaticContent(response: Login.StaticContent.Response)
}

// MARK: - LoginPresenter

final class LoginPresenter: LoginPresentationLogic {
    weak var viewController: LoginDisplayLogic?
    
    func presentLoginResult(response: Login.Authenticate.Response) {
        let viewModel: Login.Authenticate.ViewModel
        if response.success {
            viewModel = Login.Authenticate.ViewModel(isSuccess: true, message: "Добро пожаловать!")
        } else {
            viewModel = Login.Authenticate.ViewModel(isSuccess: false, message: response.errorMessage ?? "Произошла ошибка")
        }
        viewController?.displayLoginResult(viewModel)
    }
    
    func presentStaticContent(response: Login.StaticContent.Response) {
        let viewModel = Login.StaticContent.ViewModel(title: response.title, description: response.description, picture: response.picture)
        viewController?.displayStaticContent(viewModel: viewModel)
    }
}
