import SwiftUI

struct WorkoutDetailView: View {
    let workout: WorkoutHistory
    
    var body: some View {
        List {
            ForEach(workout.exercises) { exercise in
                Section(exercise.exercise.name) {
                    ForEach(exercise.sets) { set in
                        HStack {
                            Text("\(set.reps) Wdh")
                                .frame(width: 80)
                            Text("\(Int(set.weight))kg")
                                .frame(width: 80)
                            Spacer()
                            Text("\(Int(Double(set.reps) * set.weight))kg Total")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(workout.templateName)
        .navigationBarTitleDisplayMode(.inline)
    }
} 