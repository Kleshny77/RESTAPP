// PaymentPresenter.swift

import UIKit

protocol PaymentPresentationLogic: AnyObject {
  func presentPaymentResult(response: Payment.MakePayment.Response)
}

final class PaymentPresenter: PaymentPresentationLogic {
  weak var viewController: PaymentDisplayLogic?

  func presentPaymentResult(response: Payment.MakePayment.Response) {
    let vm: Payment.MakePayment.ViewModel
    if response.isSuccess {
      vm = .init(title: "Успех", message: "Заказ успешно оформлен и оплачен")
    } else {
      vm = .init(
        title: "Ошибка",
        message: response.errorMessage ?? "Неизвестная ошибка"
      )
    }
    viewController?.displayPaymentResult(viewModel: vm)
  }
}
