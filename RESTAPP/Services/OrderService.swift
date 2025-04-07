// OrderService.swift

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
    /// Возвращает все заказы текущего пользователя
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
        // Timestamp → Date
        let ts: Date?
        if let t = data["createdAt"] as? Timestamp {
          ts = t.dateValue()
        } else {
          ts = nil
        }
        // мапим OrderItem
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
  }
