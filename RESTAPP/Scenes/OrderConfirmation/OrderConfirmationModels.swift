//
//  OrderConfirmationModels.swift
//  RESTAPP
//
//  Created by Артём on 03.04.2025.
//

enum OrderConfirmation {
    enum CompleteOrder {
        struct Request {}
        struct Response {}
        struct ViewModel {}
    }
    
    enum ShowOrder {
        struct Request {}
        
        struct Response {
            let items: [OrderItem]
        }
        
        struct ViewModel {
            struct Item {
                let name: String
                let quantity: Int
                let price: Int
            }
            
            let items: [Item]
        }
    }
}
