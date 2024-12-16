import SwiftUI

struct ProductDetailView: View {
    let product: ScannedProduct
    @StateObject private var nutritionStore = NutritionStore()
    @State private var selectedMealType = MealType.snack
    @State private var servingSize: Double
    @Environment(\.dismiss) private var dismiss
    
    init(product: ScannedProduct) {
        self.product = product
        _servingSize = State(initialValue: product.nutritionFacts.servingSize)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Produkt Info") {
                    Text(product.name)
                        .font(.headline)
                    Text("Barcode: \(product.barcode)")
                        .foregroundColor(.secondary)
                }
                
                Section("Portion") {
                    HStack {
                        Text("Menge:")
                        Spacer()
                        TextField("Menge", value: $servingSize, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text(product.nutritionFacts.servingUnit)
                    }
                    
                    Picker("Mahlzeit", selection: $selectedMealType) {
                        Text("Frühstück").tag(MealType.breakfast)
                        Text("Mittagessen").tag(MealType.lunch)
                        Text("Snack").tag(MealType.snack)
                    }
                }
                
                Section("Nährwerte") {
                    NutritionRow(label: "Kalorien", value: product.nutritionFacts.calories, unit: "kcal")
                    NutritionRow(label: "Protein", value: product.nutritionFacts.protein, unit: "g")
                    NutritionRow(label: "Kohlenhydrate", value: product.nutritionFacts.carbs, unit: "g")
                    NutritionRow(label: "Fette", value: product.nutritionFacts.fats, unit: "g")
                }
            }
            .navigationTitle("Produkt Details")
            .navigationBarItems(
                leading: Button("Abbrechen") { dismiss() },
                trailing: Button("Hinzufügen") { addToMeal() }
            )
        }
    }
    
    private func addToMeal() {
        let foodItem = FoodItem(
            id: UUID(),
            name: product.name,
            barcode: product.barcode,
            calories: product.nutritionFacts.calories,
            protein: product.nutritionFacts.protein,
            carbs: product.nutritionFacts.carbs,
            fats: product.nutritionFacts.fats,
            servingSize: servingSize,
            servingUnit: product.nutritionFacts.servingUnit,
            timestamp: Date(),
            mealType: selectedMealType
        )
        
        nutritionStore.addFoodItem(foodItem)
        dismiss()
    }
}

struct NutritionRow: View {
    let label: String
    let value: Double
    let unit: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(Int(value))\(unit)")
                .foregroundColor(.secondary)
        }
    }
} 