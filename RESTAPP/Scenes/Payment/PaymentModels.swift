//
//  PaymentModels.swift
//  RESTAPP
//
//  Created by Артём on 21.04.2025.
//

import Foundation

enum Payment {
    enum MakePayment {
        struct Request {
            let amount: Int
        }
        struct Response {
            let success: Bool
            let errorMessage: String?
        }
        struct ViewModel {
            let title: String
            let message: String
            let isSuccess: Bool
        }
    }
}
