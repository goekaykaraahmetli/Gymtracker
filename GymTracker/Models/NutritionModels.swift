import Foundation

struct FoodItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let barcode: String?
    let calories: Double
    let protein: Double
    let carbs: Double
    let fats: Double
    let servingSize: Double
    let servingUnit: String
    let timestamp: Date
    var mealType: MealType
}

enum MealType: String, Codable, Identifiable {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"
    case snack = "snack"
    
    var id: String { self.rawValue }
}

struct ScannedProduct: Identifiable {
    let id: UUID
    let barcode: String
    let name: String
    let nutritionFacts: NutritionFacts
}

struct NutritionFacts: Codable {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fats: Double
    let servingSize: Double
    let servingUnit: String
} 