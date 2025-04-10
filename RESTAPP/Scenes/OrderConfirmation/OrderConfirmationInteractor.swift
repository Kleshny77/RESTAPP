//
//  OrderConfirmationInteractor.swift
//  RESTAPP
//
//  Created by Артём on 03.04.2025.
//

protocol OrderConfirmationBusinessLogic {
    func completeOrder(request: OrderConfirmation.CompleteOrder.Request)
    func loadOrder(request: OrderConfirmation.ShowOrder.Request)
}

final class OrderConfirmationInteractor: OrderConfirmationBusinessLogic {
    var presenter: OrderConfirmationPresentationLogic?
    private let orderService: OrderService
    private let orderId: String
    
    init(orderService: OrderService, orderId: String) {
        self.orderService = orderService
        self.orderId = orderId
    }
    
    func completeOrder(request: OrderConfirmation.CompleteOrder.Request) {
        Task {
            do {
                try await orderService.completeOrder(id: orderId)
                await MainActor.run {
                    presenter?.presentOrderCompleted(response: .init())
                }
            } catch {
                print("Error completing order:", error)
            }
        }
    }
    
    func loadOrder(request: OrderConfirmation.ShowOrder.Request) {
        Task {
            do {
                if let order = try await orderService.getOrder(by: orderId) {
                    await MainActor.run {
                        presenter?.presentOrder(response: .init(items: order.items))
                    }
                }
            } catch {
                print("Error loading order:", error)
            }
        }
    }
} 
