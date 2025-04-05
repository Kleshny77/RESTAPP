import UIKit

protocol CartPresentationLogic {
    func presentCart(response: Cart.Load.Response)
}

final class CartPresenter: CartPresentationLogic {
    weak var viewController: CartDisplayLogic?
    
    func presentCart(response: Cart.Load.Response) {
        let items = response.items.map {
            CartItemViewModel(
                meal: $0.meal,
                imageURL: $0.meal.imageURL,
                name: $0.meal.name,
                weightText: "\($0.meal.weight) г",
                count: $0.count,
                priceText: "\($0.meal.price * $0.count) ₽"
            )
        }
        let totalText = "Итого: \(Int(response.total)) ₽"
        let vm = Cart.Load.ViewModel(items: items, totalText: totalText)
        viewController?.displayCart(viewModel: vm)
    }
}
