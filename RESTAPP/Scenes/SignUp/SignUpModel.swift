//
//  SignUpModel.swift
//  RESTAPP
//
//  Created by Артём on 20.03.2025.
//

import UIKit

// MARK: - SignUp Models
enum SignUp {
    enum Register {
        struct Request {
            let fullName: String
            let email: String
            let password: String
            let confirmPassword: String
        }
        struct Response {
            let success: Bool
            let errorMessage: String?
        }
        struct ViewModel {
            let isSuccess: Bool
            let message: String
        }
    }
    enum StaticContent {
        struct Response {
            let title: String
            let description: String
            let picture: UIImage
        }
        struct ViewModel {
            let title: String
            let description: String
            let picture: UIImage
        }
    }
}
