import SwiftUI

struct AddMealView: View {
    let mealType: MealType
    @Environment(\.dismiss) private var dismiss
    @StateObject private var nutritionStore = NutritionStore()
    @State private var searchText = ""
    @State private var showingScanner = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Lebensmittel suchen", text: $searchText)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()
                
                // Scan button
                Button(action: { showingScanner = true }) {
                    HStack {
                        Image(systemName: "barcode.viewfinder")
                        Text("Barcode scannen")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle(mealTypeTitle)
            .navigationBarItems(trailing: Button("Fertig") { dismiss() })
            .sheet(isPresented: $showingScanner) {
                ScannerView()
            }
        }
    }
    
    private var mealTypeTitle: String {
        switch mealType {
        case .breakfast:
            return "Frühstück"
        case .lunch:
            return "Mittagessen"
        case .dinner:
            return "Abendessen"
        case .snack:
            return "Snack"
        }
    }
} 