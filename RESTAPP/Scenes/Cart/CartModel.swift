import UIKit

enum Cart {
    enum Load {
        struct Request {}
        struct Response {
            let items: [(meal: Meal, count: Int)]
            let total: Int
        }
        struct ViewModel {
            let items: [CartItemViewModel]
            let totalText: String
        }
    }
}

struct CartItemViewModel {
    let meal: Meal
    let imageURL: String
    let name: String
    let weightText: String
    let count: Int
    let priceText: String
}
