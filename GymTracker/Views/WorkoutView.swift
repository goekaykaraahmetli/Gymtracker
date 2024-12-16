import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    @State private var showingTemplateCreator = false
    
    var body: some View {
        NavigationView {
            List {
                if workoutStore.activeWorkout != nil {
                    Section {
                        NavigationLink("Aktives Training fortsetzen") {
                            ActiveWorkoutView()
                        }
                        .foregroundColor(.blue)
                        .bold()
                    }
                }
                
                Section("Trainingsvorlagen") {
                    ForEach(workoutStore.workoutTemplates) { template in
                        NavigationLink(template.name) {
                            WorkoutTemplateDetailView(template: template)
                        }
                    }
                    .onDelete { indexSet in
                        workoutStore.deleteTemplate(at: indexSet)
                    }
                    
                    Button(action: { showingTemplateCreator = true }) {
                        Label("Neue Vorlage erstellen", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("Training")
            .sheet(isPresented: $showingTemplateCreator) {
                WorkoutTemplateCreatorView()
            }
        }
    }
}

struct WorkoutTemplateCreatorView: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    @Environment(\.dismiss) private var dismiss
    @State private var templateName = ""
    @State private var selectedExercises: Set<Exercise> = []
    @State private var selectedMuscleGroup: MuscleGroup?
    @State private var showingCustomExerciseSheet = false
    
    var filteredExercises: [Exercise] {
        guard let muscleGroup = selectedMuscleGroup else {
            return workoutStore.predefinedExercises
        }
        return workoutStore.predefinedExercises.filter { $0.muscleGroup == muscleGroup }
    }
    
    private struct ExerciseRow: View {
        let exercise: Exercise
        let isSelected: Bool
        let onTap: () -> Void
        
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(exercise.name)
                        .font(.headline)
                    Text(exercise.equipment.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Name der Vorlage") {
                    TextField("z.B. Push Day", text: $templateName)
                }
                
                Section("Muskelgruppe filtern") {
                    Picker("Muskelgruppe", selection: $selectedMuscleGroup) {
                        Text("Alle").tag(nil as MuscleGroup?)
                        ForEach(MuscleGroup.allCases, id: \.self) { group in
                            Text(group.rawValue).tag(group as MuscleGroup?)
                        }
                    }
                }
                
                Section(header: customExerciseHeader) {
                    ForEach(filteredExercises) { exercise in
                        ExerciseRow(
                            exercise: exercise,
                            isSelected: selectedExercises.contains(exercise),
                            onTap: {
                                if selectedExercises.contains(exercise) {
                                    selectedExercises.remove(exercise)
                                } else {
                                    selectedExercises.insert(exercise)
                                }
                            }
                        )
                    }
                }
            }
            .navigationTitle("Neue Trainingsvorlage")
            .navigationBarItems(
                leading: Button("Abbrechen") { dismiss() },
                trailing: Button("Fertig") {
                    workoutStore.createWorkoutTemplate(
                        name: templateName,
                        exercises: Array(selectedExercises)
                    )
                    dismiss()
                }
                .disabled(templateName.isEmpty || selectedExercises.isEmpty)
            )
            .sheet(isPresented: $showingCustomExerciseSheet) {
                CustomExerciseCreatorView(onExerciseCreated: { exercise in
                    selectedExercises.insert(exercise)
                })
            }
        }
    }
    
    private var customExerciseHeader: some View {
        HStack {
            Text("Übungen auswählen")
            Spacer()
            Button(action: { showingCustomExerciseSheet = true }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
            }
        }
    }
}

// Add this new view for creating custom exercises
struct CustomExerciseCreatorView: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    @Environment(\.dismiss) private var dismiss
    let onExerciseCreated: (Exercise) -> Void
    
    @State private var exerciseName = ""
    @State private var selectedMuscleGroup: MuscleGroup = .chest
    @State private var selectedEquipment: Equipment = .barbell
    @State private var selectedCategory: ExerciseCategory = .compound
    
    var body: some View {
        NavigationView {
            Form {
                Section("Übungsname") {
                    TextField("Name der Übung", text: $exerciseName)
                }
                
                Section("Muskelgruppe") {
                    Picker("Muskelgruppe", selection: $selectedMuscleGroup) {
                        ForEach(MuscleGroup.allCases, id: \.self) { group in
                            Text(group.rawValue).tag(group)
                        }
                    }
                }
                
                Section("Equipment") {
                    Picker("Equipment", selection: $selectedEquipment) {
                        ForEach([Equipment.barbell, .dumbbell, .bodyweight], id: \.self) { equipment in
                            Text(equipment.rawValue).tag(equipment)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Kategorie") {
                    Picker("Kategorie", selection: $selectedCategory) {
                        Text("Compound").tag(ExerciseCategory.compound)
                        Text("Isolation").tag(ExerciseCategory.isolation)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Neue Übung")
            .navigationBarItems(
                leading: Button("Abbrechen") { dismiss() },
                trailing: Button("Hinzufügen") {
                    let exercise = Exercise(
                        name: exerciseName,
                        category: selectedCategory,
                        muscleGroup: selectedMuscleGroup,
                        equipment: selectedEquipment
                    )
                    workoutStore.addCustomExercise(exercise)
                    onExerciseCreated(exercise)
                    dismiss()
                }
                .disabled(exerciseName.isEmpty)
            )
        }
    }
}

#Preview {
    WorkoutView()
        .environmentObject(WorkoutStore())
} 