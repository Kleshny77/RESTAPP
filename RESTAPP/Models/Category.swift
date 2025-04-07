import Foundation

struct Category: Codable, Hashable {
    let id: String
    let name: String
    var meals: [Meal]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case meals
    }
    
    init(id: String, name: String, meals: [Meal] = []) {
        self.id = id
        self.name = name
        self.meals = meals
    }
} 