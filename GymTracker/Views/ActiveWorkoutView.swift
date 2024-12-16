import SwiftUI

struct ActiveWorkoutView: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            if let workout = workoutStore.activeWorkout {
                ForEach(workout.exercises) { exercise in
                    ExerciseSection(
                        exercise: exercise,
                        exerciseIndex: workout.exercises.firstIndex(where: { $0.id == exercise.id }) ?? 0
                    )
                }
            }
        }
        .navigationTitle("Aktives Training")
        .navigationBarItems(trailing: endWorkoutButton)
    }
    
    private var endWorkoutButton: some View {
        Button("Beenden") {
            workoutStore.finishWorkout()
            dismiss()
        }
    }
}

struct ExerciseSection: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    let exercise: WorkoutExercise
    let exerciseIndex: Int
    
    var body: some View {
        Section(exercise.exercise.name) {
            ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { setIndex, set in
                SetRow(
                    set: set,
                    setIndex: setIndex,
                    exerciseIndex: exerciseIndex
                )
            }
        }
    }
}

struct SetRow: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    let set: WorkoutSet
    let setIndex: Int
    let exerciseIndex: Int
    
    var body: some View {
        HStack {
            Text("Satz \(setIndex + 1)")
                .font(.headline)
                .frame(width: 80, alignment: .leading)
            
            if set.completed {
                CompletedSetView(set: set)
            } else {
                SetInputRow(
                    reps: set.reps,
                    weight: set.weight,
                    onComplete: { reps, weight in
                        workoutStore.completeSet(
                            exerciseIndex: exerciseIndex,
                            setIndex: setIndex,
                            reps: reps,
                            weight: weight
                        )
                    }
                )
            }
        }
        .frame(height: 44) // Apple's minimum touch target
    }
}

struct CompletedSetView: View {
    let set: WorkoutSet
    
    var body: some View {
        HStack {
            Text("\(set.reps) Wdh")
                .font(.body)
                .frame(width: 80)
            Text("\(Int(set.weight))kg")
                .font(.body)
                .frame(width: 80)
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title3)
        }
    }
}

struct SetInputRow: View {
    let reps: Int
    let weight: Double
    let onComplete: (Int, Double) -> Void
    
    @State private var inputReps: String = ""
    @State private var inputWeight: String = ""
    
    var body: some View {
        HStack {
            TextField("Wdh", text: $inputReps)
                .keyboardType(.numberPad)
                .frame(width: 80)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.body)
            
            TextField("kg", text: $inputWeight)
                .keyboardType(.decimalPad)
                .frame(width: 80)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.body)
            
            Button(action: {
                if let reps = Int(inputReps),
                   let weight = Double(inputWeight.replacingOccurrences(of: ",", with: ".")) {
                    onComplete(reps, weight)
                }
            }) {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.blue)
                    .font(.title3)
                    .frame(width: 44, height: 44) // Apple's minimum touch target
            }
            .disabled(inputReps.isEmpty || inputWeight.isEmpty)
        }
    }
}

#Preview {
    ActiveWorkoutView()
        .environmentObject(WorkoutStore())
} 