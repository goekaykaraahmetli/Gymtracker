import SwiftUI

struct WorkoutTemplateDetailView: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    let template: WorkoutTemplate
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Section {
                ForEach(template.exercises) { exercise in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .font(.headline)
                        HStack {
                            Text(exercise.muscleGroup.rawValue)
                            Text("•")
                            Text(exercise.equipment.rawValue)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(template.name)
        .navigationBarItems(trailing: Button("Training starten") {
            workoutStore.startWorkout(from: template)
            dismiss()
        })
    }
}

#Preview {
    WorkoutTemplateDetailView(template: WorkoutTemplate(name: "Preview Template", exercises: []))
        .environmentObject(WorkoutStore())
} 