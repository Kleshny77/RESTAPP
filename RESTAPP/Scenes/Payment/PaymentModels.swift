//
//  PaymentModels.swift
//  RESTAPP
//
//  Created by Артём on 02.04.2025.
//

import Foundation

enum Payment {
    enum MakePayment {
        struct Request {
            let userId: String
            let restaurantId: String
            let items: [OrderItem]
        }
        struct Response {
            let isSuccess: Bool
            let errorMessage: String?
        }
        struct ViewModel {
            let title: String
            let message: String
        }
    }
}
