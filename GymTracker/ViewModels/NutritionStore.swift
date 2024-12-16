import CoreData
import Foundation

class NutritionStore: ObservableObject {
    private let coreDataManager = CoreDataManager.shared
    
    @Published var breakfastItems: [FoodItem] = []
    @Published var lunchItems: [FoodItem] = []
    @Published var snackItems: [FoodItem] = []
    @Published var dinnerItems: [FoodItem] = []
    
    @Published var todaysCalories: Double = 0
    @Published var todaysProtein: Double = 0
    @Published var todaysCarbs: Double = 0
    @Published var todaysFats: Double = 0
    
    var breakfastCalories: Double {
        breakfastItems.reduce(0) { $0 + $1.calories }
    }
    
    var lunchCalories: Double {
        lunchItems.reduce(0) { $0 + $1.calories }
    }
    
    var snackCalories: Double {
        snackItems.reduce(0) { $0 + $1.calories }
    }
    
    var dinnerCalories: Double {
        dinnerItems.reduce(0) { $0 + $1.calories }
    }
    
    init() {
        loadData()
        calculateTotals()
    }
    
    private func loadData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        let request: NSFetchRequest<StoredFoodItem> = StoredFoodItem.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", today as NSDate, tomorrow as NSDate)
        
        do {
            let storedItems = try coreDataManager.viewContext.fetch(request)
            
            breakfastItems = storedItems
                .filter { $0.mealType == MealType.breakfast.rawValue }
                .map(convertToFoodItem)
            
            lunchItems = storedItems
                .filter { $0.mealType == MealType.lunch.rawValue }
                .map(convertToFoodItem)
            
            snackItems = storedItems
                .filter { $0.mealType == MealType.snack.rawValue }
                .map(convertToFoodItem)
            
            dinnerItems = storedItems
                .filter { $0.mealType == MealType.dinner.rawValue }
                .map(convertToFoodItem)
            
        } catch {
            print("Failed to fetch stored items: \(error.localizedDescription)")
        }
    }
    
    private func calculateTotals() {
        let allItems = breakfastItems + lunchItems + dinnerItems + snackItems
        
        todaysCalories = allItems.reduce(0) { $0 + $1.calories }
        todaysProtein = allItems.reduce(0) { $0 + $1.protein }
        todaysCarbs = allItems.reduce(0) { $0 + $1.carbs }
        todaysFats = allItems.reduce(0) { $0 + $1.fats }
    }
    
    func addFoodItem(_ item: FoodItem) {
        let storedItem = StoredFoodItem(context: coreDataManager.viewContext)
        storedItem.id = item.id
        storedItem.name = item.name
        storedItem.barcode = item.barcode
        storedItem.calories = item.calories
        storedItem.protein = item.protein
        storedItem.carbs = item.carbs
        storedItem.fats = item.fats
        storedItem.servingSize = item.servingSize
        storedItem.servingUnit = item.servingUnit
        storedItem.mealType = item.mealType.rawValue
        storedItem.timestamp = item.timestamp
        
        coreDataManager.save()
        loadData()
        calculateTotals()
    }
    
    private func convertToFoodItem(_ storedItem: StoredFoodItem) -> FoodItem {
        FoodItem(
            id: storedItem.id ?? UUID(),
            name: storedItem.name ?? "",
            barcode: storedItem.barcode,
            calories: storedItem.calories,
            protein: storedItem.protein,
            carbs: storedItem.carbs,
            fats: storedItem.fats,
            servingSize: storedItem.servingSize,
            servingUnit: storedItem.servingUnit ?? "g",
            timestamp: storedItem.timestamp ?? Date(),
            mealType: MealType(rawValue: storedItem.mealType ?? "") ?? .snack
        )
    }
} 