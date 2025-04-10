//
//  OrderService.swift
//  RESTAPP
//
//  Created by Артём on 27.03.2025.
//

import FirebaseFirestore

final class OrderService {
  static let shared = OrderService()
  private let db = Firestore.firestore()
  private init() {}

  func placeOrder(
    userId: String,
    restaurantId: String,
    items: [OrderItem],
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    let total = items.reduce(0) { $0 + $1.price * $1.quantity }
    let ref = db.collection("orders").document()
    let data: [String:Any] = [
      "userId": userId,
      "restaurantId": restaurantId,
      "createdAt": FieldValue.serverTimestamp(),
      "status": "new",
      "total": total,
      "items": items.map {
        ["mealId":   $0.mealId,
         "name":     $0.name,
         "price":    $0.price,
         "quantity": $0.quantity]
      }
    ]
    ref.setData(data) { err in
      if let e = err { completion(.failure(e)) }
      else          { completion(.success(ref.documentID)) }
    }
  }
}

extension OrderService {
    func fetchOrders(for userId: String) async throws -> [Order] {
      let snapshot = try await db
        .collection("orders")
        .whereField("userId", isEqualTo: userId)
        .getDocuments()
      return snapshot.documents.compactMap { doc in
        let data = doc.data()
        guard
          let restaurantId = data["restaurantId"]   as? String,
          let status       = data["status"]         as? String,
          let total        = data["total"]          as? Int,
          let itemsRaw     = data["items"]          as? [[String:Any]]
        else {
          return nil
        }
        let ts: Date?
        if let t = data["createdAt"] as? Timestamp {
          ts = t.dateValue()
        } else {
          ts = nil
        }
        let items: [OrderItem] = itemsRaw.compactMap { map in
          guard
            let mealId   = map["mealId"]   as? String,
            let name     = map["name"]     as? String,
            let price    = map["price"]    as? Int,
            let quantity = map["quantity"] as? Int
          else { return nil }
          return OrderItem(mealId: mealId, name: name, price: price, quantity: quantity)
        }
        return Order(
          id:           doc.documentID,
          userId:       userId,
          restaurantId: restaurantId,
          createdAt:    ts,
          status:       status,
          total:        total,
          items:        items
        )
      }
    }

    func completeOrder(id: String) async throws {
        try await db.collection("orders")
            .document(id)
            .updateData([
                "status": "completed",
                "completedAt": FieldValue.serverTimestamp()
            ])
    }

    func hasActiveOrders(for userId: String) async throws -> Bool {
        let snapshot = try await db
            .collection("orders")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: "new")
            .getDocuments()
        return !snapshot.documents.isEmpty
    }
    
    func getActiveOrder(for userId: String) async throws -> Order? {
        let snapshot = try await db
            .collection("orders")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: "new")
            .getDocuments()
        
        return snapshot.documents.first.flatMap { doc in
            let data = doc.data()
            guard
                let restaurantId = data["restaurantId"] as? String,
                let status = data["status"] as? String,
                let total = data["total"] as? Int,
                let itemsRaw = data["items"] as? [[String:Any]]
            else {
                return nil
            }
            
            let ts: Date?
            if let t = data["createdAt"] as? Timestamp {
                ts = t.dateValue()
            } else {
                ts = nil
            }
            
            let items: [OrderItem] = itemsRaw.compactMap { map in
                guard
                    let mealId = map["mealId"] as? String,
                    let name = map["name"] as? String,
                    let price = map["price"] as? Int,
                    let quantity = map["quantity"] as? Int
                else { return nil }
                return OrderItem(mealId: mealId, name: name, price: price, quantity: quantity)
            }
            
            return Order(
                id: doc.documentID,
                userId: userId,
                restaurantId: restaurantId,
                createdAt: ts,
                status: status,
                total: total,
                items: items
            )
        }
    }
    
    func getOrder(by id: String) async throws -> Order? {
        let doc = try await db.collection("orders").document(id).getDocument()
        guard 
            let data = doc.data(),
            let userId = data["userId"] as? String,
            let restaurantId = data["restaurantId"] as? String,
            let status = data["status"] as? String,
            let total = data["total"] as? Int,
            let itemsRaw = data["items"] as? [[String:Any]]
        else {
            return nil
        }
        
        let ts: Date?
        if let t = data["createdAt"] as? Timestamp {
            ts = t.dateValue()
        } else {
            ts = nil
        }
        
        let items: [OrderItem] = itemsRaw.compactMap { map in
            guard
                let mealId = map["mealId"] as? String,
                let name = map["name"] as? String,
                let price = map["price"] as? Int,
                let quantity = map["quantity"] as? Int
            else { return nil }
            return OrderItem(mealId: mealId, name: name, price: price, quantity: quantity)
        }
        
        return Order(
            id: doc.documentID,
            userId: userId,
            restaurantId: restaurantId,
            createdAt: ts,
            status: status,
            total: total,
            items: items
        )
    }
}
