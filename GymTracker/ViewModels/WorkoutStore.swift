import Foundation

class WorkoutStore: ObservableObject {
    @Published var predefinedExercises: [Exercise] = []
    @Published var workoutTemplates: [WorkoutTemplate] = []
    @Published var activeWorkout: ActiveWorkout?
    @Published var workoutHistory: [WorkoutHistory] = []
    @Published var personalRecords: [String: PersonalRecord] = [:] // Exercise.id: PersonalRecord
    
    init() {
        loadPredefinedExercises()
        loadSavedData()
    }
    
    private func loadPredefinedExercises() {
        // In a real app, you might load these from an API or database
        predefinedExercises = [
            Exercise(name: "Bankdrücken", category: .compound, muscleGroup: .chest, equipment: .barbell),
            Exercise(name: "Schrägbankdrücken", category: .compound, muscleGroup: .chest, equipment: .barbell),
            Exercise(name: "Kurzhantel-Drücken", category: .compound, muscleGroup: .chest, equipment: .dumbbell),
            Exercise(name: "Klimmzüge", category: .compound, muscleGroup: .back, equipment: .bodyweight),
            Exercise(name: "Kreuzheben", category: .compound, muscleGroup: .back, equipment: .barbell),
            Exercise(name: "Kniebeugen", category: .compound, muscleGroup: .legs, equipment: .barbell),
            Exercise(name: "Schulterdrücken", category: .compound, muscleGroup: .shoulders, equipment: .barbell),
            Exercise(name: "Bizeps Curls", category: .isolation, muscleGroup: .arms, equipment: .dumbbell),
            Exercise(name: "Trizeps Extensions", category: .isolation, muscleGroup: .arms, equipment: .cable)
        ]
    }
    
    private func loadSavedData() {
        if let historyData = UserDefaults.standard.data(forKey: "WorkoutHistory"),
           let history = try? JSONDecoder().decode([WorkoutHistory].self, from: historyData) {
            workoutHistory = history
        }
        
        if let recordsData = UserDefaults.standard.data(forKey: "PersonalRecords"),
           let records = try? JSONDecoder().decode([String: PersonalRecord].self, from: recordsData) {
            personalRecords = records
        }
        
        if let templatesData = UserDefaults.standard.data(forKey: "WorkoutTemplates"),
           let templates = try? JSONDecoder().decode([WorkoutTemplate].self, from: templatesData) {
            workoutTemplates = templates
        }
    }
    
    private func saveData() {
        if let historyData = try? JSONEncoder().encode(workoutHistory) {
            UserDefaults.standard.set(historyData, forKey: "WorkoutHistory")
        }
        
        if let recordsData = try? JSONEncoder().encode(personalRecords) {
            UserDefaults.standard.set(recordsData, forKey: "PersonalRecords")
        }
        
        if let templatesData = try? JSONEncoder().encode(workoutTemplates) {
            UserDefaults.standard.set(templatesData, forKey: "WorkoutTemplates")
        }
        
        UserDefaults.standard.synchronize()
    }
    
    func createWorkoutTemplate(name: String, exercises: [Exercise]) {
        let template = WorkoutTemplate(name: name, exercises: exercises)
        workoutTemplates.append(template)
        saveData()
    }
    
    func startWorkout(from template: WorkoutTemplate) {
        let workoutExercises = template.exercises.map { exercise in
            WorkoutExercise(exercise: exercise, sets: [WorkoutSet(), WorkoutSet(), WorkoutSet()])
        }
        activeWorkout = ActiveWorkout(exercises: workoutExercises)
    }
    
    func completeSet(exerciseIndex: Int, setIndex: Int, reps: Int, weight: Double) {
        guard var workout = activeWorkout else { return }
        workout.exercises[exerciseIndex].sets[setIndex].reps = reps
        workout.exercises[exerciseIndex].sets[setIndex].weight = weight
        workout.exercises[exerciseIndex].sets[setIndex].completed = true
        activeWorkout = workout
    }
    
    func finishWorkout() {
        guard let workout = activeWorkout,
              let template = workoutTemplates.first(where: { template in
                  template.exercises.map { $0.id }.sorted() == workout.exercises.map { $0.exercise.id }.sorted()
              }) else {
            return
        }
        
        // Convert active workout to history
        let completedExercises = workout.exercises.map { exercise in
            let completedSets = exercise.sets
                .filter { $0.completed }  // Only include completed sets
                .map { CompletedSet(reps: $0.reps, weight: $0.weight) }
            return CompletedExercise(exercise: exercise.exercise, sets: completedSets)
        }
        
        // Only create history if there are completed sets
        if completedExercises.contains(where: { !$0.sets.isEmpty }) {
            let history = WorkoutHistory(
                templateName: template.name,
                date: workout.startTime,
                exercises: completedExercises
            )
            workoutHistory.append(history)
            
            // Update personal records for each exercise
            for exercise in completedExercises {
                updatePersonalRecords(for: exercise)
            }
        }
        
        // Clear active workout
        activeWorkout = nil
        
        // Save to persistent storage
        saveData()
    }
    
    private func updatePersonalRecords(for exercise: CompletedExercise) {
        let exerciseId = exercise.exercise.id.uuidString
        
        // Get current PR or create new one
        var currentPR = personalRecords[exerciseId] ?? PersonalRecord(
            exercise: exercise.exercise,
            date: Date(),
            maxWeight: 0,
            maxReps: 0,
            maxVolumeSet: (reps: 0, weight: 0)
        )
        
        // Find max weight (1RM)
        if let maxWeightSet = exercise.sets.max(by: { $0.weight < $1.weight }) {
            if maxWeightSet.weight > currentPR.maxWeight {
                currentPR = PersonalRecord(
                    exercise: exercise.exercise,
                    date: Date(),
                    maxWeight: maxWeightSet.weight,
                    maxReps: currentPR.maxReps,
                    maxVolumeSet: (reps: currentPR.maxVolumeSet.reps, 
                                 weight: currentPR.maxVolumeSet.weight)
                )
            }
        }
        
        // Find max reps
        if let maxRepsSet = exercise.sets.max(by: { $0.reps < $1.reps }) {
            if maxRepsSet.reps > currentPR.maxReps {
                currentPR = PersonalRecord(
                    exercise: exercise.exercise,
                    date: Date(),
                    maxWeight: currentPR.maxWeight,
                    maxReps: maxRepsSet.reps,
                    maxVolumeSet: (reps: currentPR.maxVolumeSet.reps, 
                                 weight: currentPR.maxVolumeSet.weight)
                )
            }
        }
        
        // Find best volume set (reps × weight)
        let volumeSets = exercise.sets.map { set in
            (reps: set.reps, weight: set.weight, volume: Double(set.reps) * set.weight)
        }
        
        if let bestSet = volumeSets.max(by: { $0.volume < $1.volume }) {
            let currentVolume = Double(currentPR.maxVolumeSet.reps) * currentPR.maxVolumeSet.weight
            if bestSet.volume > currentVolume {
                currentPR = PersonalRecord(
                    exercise: exercise.exercise,
                    date: Date(),
                    maxWeight: currentPR.maxWeight,
                    maxReps: currentPR.maxReps,
                    maxVolumeSet: (reps: bestSet.reps, weight: bestSet.weight)
                )
            }
        }
        
        // Update the record
        personalRecords[exerciseId] = currentPR
    }
    
    func addCustomExercise(_ exercise: Exercise) {
        predefinedExercises.append(exercise)
        saveData()
    }
    
    func deleteTemplate(at indexSet: IndexSet) {
        workoutTemplates.remove(atOffsets: indexSet)
        saveData()
    }
} 