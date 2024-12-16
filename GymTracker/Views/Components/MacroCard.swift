import SwiftUI

struct MacroCard: View {
    let title: String
    let amount: Double
    let target: Double
    let unit: String
    let color: Color
    
    private var progress: Double {
        min(amount / target, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("\(Int(amount))\(unit)")
                .font(.headline)
            
            ProgressView(value: progress)
                .tint(color)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 