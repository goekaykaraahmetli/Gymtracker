import SwiftUI

struct FoodItemRow: View {
    let item: FoodItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.headline)
            
            HStack {
                Text("\(Int(item.calories)) kcal")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(item.servingSize))\(item.servingUnit)")
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
            
            HStack(spacing: 12) {
                MacroText(value: item.protein, unit: "g", label: "Protein")
                MacroText(value: item.carbs, unit: "g", label: "Carbs")
                MacroText(value: item.fats, unit: "g", label: "Fette")
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

private struct MacroText: View {
    let value: Double
    let unit: String
    let label: String
    
    var body: some View {
        Text("\(Int(value))\(unit) \(label)")
            .foregroundColor(.secondary)
    }
} 