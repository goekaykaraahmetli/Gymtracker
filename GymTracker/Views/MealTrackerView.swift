import SwiftUI

struct MealTrackerView: View {
    @StateObject private var nutritionStore = NutritionStore()
    
    var body: some View {
        NavigationView {
            List {
                Section("Frühstück") {
                    ForEach(nutritionStore.breakfastItems) { item in
                        FoodItemRow(item: item)
                    }
                    addMealButton(for: .breakfast)
                }
                
                Section("Mittagessen") {
                    ForEach(nutritionStore.lunchItems) { item in
                        FoodItemRow(item: item)
                    }
                    addMealButton(for: .lunch)
                }
                
                Section("Snacks") {
                    ForEach(nutritionStore.snackItems) { item in
                        FoodItemRow(item: item)
                    }
                    addMealButton(for: .snack)
                }
            }
            .navigationTitle("Mahlzeiten")
        }
    }
    
    private func addMealButton(for mealType: MealType) -> some View {
        Button(action: {
            // Will implement scanning/adding logic
        }) {
            Label("Hinzufügen", systemImage: "plus.circle")
        }
    }
} 