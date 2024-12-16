import SwiftUI

struct NutritionCard: View {
    let title: String
    let current: Double
    let target: Double
    let unit: String
    let color: Color
    
    private var progress: Double {
        min(current / target, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            HStack {
                Text("\(Int(current))")
                    .font(.system(size: 34, weight: .bold))
                Text(unit)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("von \(Int(target))")
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: progress)
                .tint(color)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 