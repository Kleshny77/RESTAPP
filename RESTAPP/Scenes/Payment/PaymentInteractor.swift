//
//  PaymentInteractor.swift
//  RESTAPP
//
//  Created by Артём on 01.04.2025.
//

import Foundation

protocol PaymentBusinessLogic {
    func makePayment(request: Payment.MakePayment.Request)
}
protocol PaymentDataStore {
    var amount: Int { get }
    var items: [OrderItem] { get }
    var restaurantId: String { get }
}

final class PaymentInteractor:
    PaymentBusinessLogic,
    PaymentDataStore
{
    var presenter: PaymentPresentationLogic?
    var router: (NSObjectProtocol & PaymentRoutingLogic)?
    
    let items: [OrderItem]
    let restaurantId: String
    
    var amount: Int {
        items.reduce(0) { $0 + $1.price * $1.quantity }
    }
    
    init(items: [OrderItem], restaurantId: String) {
        self.items = items
        self.restaurantId = restaurantId
    }
    
    func makePayment(request: Payment.MakePayment.Request) {
        OrderService.shared.placeOrder(
            userId:      request.userId,
            restaurantId: request.restaurantId,
            items:       request.items
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let orderId):
                let response = Payment.MakePayment.Response(isSuccess: true, errorMessage: nil)
                self.presenter?.presentPaymentResult(response: response)
                DispatchQueue.main.async {
                    self.router?.routeToConfirmation(orderId: orderId)
                    CartService.shared.clear()
                }
            case .failure(let error):
                let response = Payment.MakePayment.Response(isSuccess: false, errorMessage: error.localizedDescription)
                self.presenter?.presentPaymentResult(response: response)
            }
        }
    }
}
