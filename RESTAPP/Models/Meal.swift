import Foundation

struct Meal: Codable, Hashable {
    let id: String
    let name: String
    let price: Int
    let weight: Int
    let kcal: Int
    let protein: Int
    let fat: Int
    let carbohydrates: Int
    
    let imageURL: String?
    let description: String?
    let composition: String?
    
    init(id: String, name: String, price: Int, weight: Int, kcal: Int, protein: Int, fat: Int, carbohydrates: Int, imageURL: String? = nil, description: String? = nil, composition: String? = nil) {
        self.id = id
        self.name = name
        self.price = price
        self.weight = weight
        self.kcal = kcal
        self.protein = protein
        self.fat = fat
        self.carbohydrates = carbohydrates
        self.imageURL = imageURL
        self.description = description
        self.composition = composition
    }
} 
