import Foundation
import FirebaseFirestore

class RestaurantService {
    static let shared = RestaurantService()
    private let db = Firestore.firestore()
    
    // Текущий выбранный ресторан
    @Published private(set) var currentRestaurant: Restaurant?
    
    private init() {}
    
    func fetchRestaurants() async throws -> [Restaurant] {
        let snapshot = try await db.collection("restaurants").getDocuments()
        return snapshot.documents.compactMap { document in
            let data = document.data()
            
            guard
                let name = data["name"] as? String,
                let openingHours = data["openingHours"] as? [String: [String: String?]]
            else {
                print("Error: Invalid restaurant data for document \(document.documentID)")
                return nil
            }
            
            let schedule = Restaurant.OpeningHours(
                monday: parseSchedule(openingHours["monday"]),
                tuesday: parseSchedule(openingHours["tuesday"]),
                wednesday: parseSchedule(openingHours["wednesday"]),
                thursday: parseSchedule(openingHours["thursday"]),
                friday: parseSchedule(openingHours["friday"]),
                saturday: parseSchedule(openingHours["saturday"]),
                sunday: parseSchedule(openingHours["sunday"])
            )
            
            return Restaurant(
                id: document.documentID,
                name: name,
                openingHours: schedule
            )
        }
    }
    
    private func parseSchedule(_ data: [String: String?]?) -> Restaurant.OpeningHours.DaySchedule {
        guard let data = data else {
            return .init(open: nil, close: nil)
        }
        return .init(open: data["open"] ?? nil, close: data["close"] ?? nil)
    }
    
    func fetchRestaurant(id: String) async throws -> Restaurant {
        let doc = try await db.collection("restaurants").document(id).getDocument()
        let data = doc.data() ?? [:]
        
        guard
            let name = data["name"] as? String,
            let openingHours = data["openingHours"] as? [String: [String: String?]]
        else {
            throw NSError(domain: "", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid restaurant data"])
        }
        
        let schedule = Restaurant.OpeningHours(
            monday: parseSchedule(openingHours["monday"]),
            tuesday: parseSchedule(openingHours["tuesday"]),
            wednesday: parseSchedule(openingHours["wednesday"]),
            thursday: parseSchedule(openingHours["thursday"]),
            friday: parseSchedule(openingHours["friday"]),
            saturday: parseSchedule(openingHours["saturday"]),
            sunday: parseSchedule(openingHours["sunday"])
        )
        
        return Restaurant(
            id: doc.documentID,
            name: name,
            openingHours: schedule
        )
    }
    
    // Установить текущий ресторан
    func setCurrentRestaurant(_ restaurant: Restaurant) {
        currentRestaurant = restaurant
        // Сохраняем выбор пользователя
        UserDefaults.standard.set(restaurant.id, forKey: "selectedRestaurantId")
    }
    
    // Загрузить последний выбранный ресторан
    func loadLastSelectedRestaurant() async throws {
        // Пробуем загрузить сохраненный ресторан
        if let savedId = UserDefaults.standard.string(forKey: "selectedRestaurantId") {
            currentRestaurant = try await fetchRestaurant(id: savedId)
            return
        }
        
        // Если нет сохраненного или его не удалось загрузить, берем первый из списка
        let restaurants = try await fetchRestaurants()
        if let firstRestaurant = restaurants.first {
            currentRestaurant = firstRestaurant
            setCurrentRestaurant(firstRestaurant)
        }
    }
}
