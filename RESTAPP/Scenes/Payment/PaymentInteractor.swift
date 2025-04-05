//
//  PaymentInteractor.swift
//  RESTAPP
//
//  Created by Артём on 21.04.2025.
//

import Foundation

protocol PaymentBusinessLogic {
    func makePayment(request: Payment.MakePayment.Request)
}
protocol PaymentDataStore {
    var amount: Int { get }
}

final class PaymentInteractor: PaymentBusinessLogic, PaymentDataStore {
    var presenter: PaymentPresentationLogic?
    var router: (NSObjectProtocol & PaymentRoutingLogic)?

    // будем хранить сумму в интеракторе
    let amount: Int

    init(amount: Int) {
        self.amount = amount
    }

    func makePayment(request: Payment.MakePayment.Request) {
        // эмулируем сетевой запрос
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            let success = true // можно random или false
            let response = Payment.MakePayment.Response(
                success: success,
                errorMessage: nil
            )
            self.presenter?.presentPaymentResult(response: response)
            if success {
                DispatchQueue.main.async {
                    self.router?.routeToConfirmation()
                }
            }
        }
    }
}
