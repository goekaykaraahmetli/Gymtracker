import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject private var nutritionStore = NutritionStore()
    @State private var showingScanner = false
    @State private var showingAddMeal = false
    @State private var selectedMealType: MealType?
    
    private let themeColor = Color.blue
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    dailyProgressSection
                    mealsSection
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    scannerButton
                }
            }
            .sheet(isPresented: $showingScanner) {
                ScannerView()
            }
            .sheet(item: $selectedMealType) { mealType in
                AddMealView(mealType: mealType)
            }
        }
    }
    
    private var dailyProgressSection: some View {
        VStack(spacing: 20) {
            caloriesProgressCard
            macroNutrientsGrid
        }
        .padding(.horizontal)
    }
    
    private var caloriesProgressCard: some View {
        HStack(alignment: .bottom, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Tägliche Kalorien")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(Int(nutritionStore.todaysCalories))")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(themeColor)
                
                Text("von 2000 kcal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            caloriesProgressCircle
        }
        .padding(20)
        .background(themeColor.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var caloriesProgressCircle: some View {
        ZStack {
            Circle()
                .stroke(themeColor.opacity(0.2), lineWidth: 12)
            
            Circle()
                .trim(from: 0, to: min(nutritionStore.todaysCalories / 2000, 1.0))
                .stroke(themeColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 80, height: 80)
    }
    
    private var macroNutrientsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            MacroCard(title: "Protein",
                     amount: nutritionStore.todaysProtein,
                      target: 150,
                     unit: "g",
                     color: themeColor)
            
            MacroCard(title: "Carbs",
                     amount: nutritionStore.todaysCarbs,
                      target: 250,
                     unit: "g",
                     color: themeColor)
            
            MacroCard(title: "Fette",
                     amount: nutritionStore.todaysFats,
                     target: 70,
                     unit: "g",
                     color: themeColor)
        }
    }
    
    private var mealsSection: some View {
        VStack(spacing: 16) {
            Text("Mahlzeiten")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                mealSections
            }
            .padding(.horizontal)
        }
    }
    
    private var mealSections: some View {
        Group {
            MealSection(title: "Frühstück",
                       items: nutritionStore.breakfastItems,
                       calories: nutritionStore.breakfastCalories,
                       icon: "sunrise.fill",
                       color: themeColor,
                       onAdd: { selectedMealType = .breakfast })
            
            MealSection(title: "Mittagessen",
                       items: nutritionStore.lunchItems,
                       calories: nutritionStore.lunchCalories,
                       icon: "sun.max.fill",
                       color: themeColor,
                       onAdd: { selectedMealType = .lunch })
            
            MealSection(title: "Abendessen",
                       items: nutritionStore.dinnerItems,
                       calories: nutritionStore.dinnerCalories,
                       icon: "moon.stars.fill",
                       color: themeColor,
                       onAdd: { selectedMealType = .dinner })
            
            MealSection(title: "Snacks",
                       items: nutritionStore.snackItems,
                       calories: nutritionStore.snackCalories,
                       icon: "apple.logo",
                       color: themeColor,
                       onAdd: { selectedMealType = .snack })
        }
    }
    
    private var scannerButton: some View {
        Button(action: { showingScanner = true }) {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 20))
                .frame(width: 44, height: 44)
        }
    }
}
  
