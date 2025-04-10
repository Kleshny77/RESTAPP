//
//  OrderConfirmationPresenter.swift
//  RESTAPP
//
//  Created by Артём on 03.04.2025.
//

protocol OrderConfirmationPresentationLogic {
    func presentOrderCompleted(response: OrderConfirmation.CompleteOrder.Response)
    func presentOrder(response: OrderConfirmation.ShowOrder.Response)
}

final class OrderConfirmationPresenter: OrderConfirmationPresentationLogic {
    weak var viewController: OrderConfirmationDisplayLogic?
    
    func presentOrderCompleted(response: OrderConfirmation.CompleteOrder.Response) {
        viewController?.displayOrderCompleted()
    }
    
    func presentOrder(response: OrderConfirmation.ShowOrder.Response) {
        let items = response.items.map { item in
            OrderConfirmation.ShowOrder.ViewModel.Item(
                name: item.name,
                quantity: item.quantity,
                price: item.price
            )
        }
        viewController?.displayOrder(viewModel: .init(items: items))
    }
} 
