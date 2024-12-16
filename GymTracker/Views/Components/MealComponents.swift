import SwiftUI

struct MealSection: View {
    let title: String
    let items: [FoodItem]
    let calories: Double
    let icon: String
    let color: Color
    let onAdd: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                    .frame(width: 44, height: 44)
                
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Text("\(Int(calories)) kcal")
                    .foregroundColor(.secondary)
                
                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(color)
                        .font(.title3)
                        .frame(width: 44, height: 44)
                }
            }
            
            if !items.isEmpty {
                ForEach(items) { item in
                    FoodItemRow(item: item)
                        .padding(.vertical, 4)
                }
            } else {
                Text("Noch keine Einträge")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
} 