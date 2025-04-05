//
//  PaymentPresenter.swift
//  RESTAPP
//
//  Created by Артём on 21.04.2025.
//

import Foundation

protocol PaymentPresentationLogic: AnyObject {
    func presentPaymentResult(response: Payment.MakePayment.Response)
}

final class PaymentPresenter: PaymentPresentationLogic {
    weak var viewController: PaymentDisplayLogic?

    func presentPaymentResult(response: Payment.MakePayment.Response) {
        let title = response.success ? "Успешно" : "Ошибка"
        let message = response.success
            ? "Оплата прошла успешно"
            : (response.errorMessage ?? "Неизвестная ошибка")
        let vm = Payment.MakePayment.ViewModel(
            title: title,
            message: message,
            isSuccess: response.success
        )
        viewController?.displayPaymentResult(viewModel: vm)
    }
}
