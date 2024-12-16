import Foundation

struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let category: ExerciseCategory
    let muscleGroup: MuscleGroup
    let equipment: Equipment
    
    init(id: UUID = UUID(), name: String, category: ExerciseCategory, muscleGroup: MuscleGroup, equipment: Equipment) {
        self.id = id
        self.name = name
        self.category = category
        self.muscleGroup = muscleGroup
        self.equipment = equipment
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        lhs.id == rhs.id
    }
}

enum ExerciseCategory: String, Codable {
    case compound = "Compound"
    case isolation = "Isolation"
}

enum MuscleGroup: String, Codable, CaseIterable {
    case chest = "Brust"
    case back = "Rücken"
    case legs = "Beine"
    case shoulders = "Schultern"
    case arms = "Arme"
    case core = "Core"
}

enum Equipment: String, Codable {
    case barbell = "Langhantel"
    case dumbbell = "Kurzhantel"
    case machine = "Maschine"
    case bodyweight = "Körpergewicht"
    case cable = "Kabelzug"
}

struct WorkoutSet: Identifiable, Codable {
    let id: UUID
    var reps: Int
    var weight: Double
    var completed: Bool
    
    init(id: UUID = UUID(), reps: Int = 0, weight: Double = 0, completed: Bool = false) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.completed = completed
    }
}

struct WorkoutExercise: Identifiable, Codable {
    let id: UUID
    let exercise: Exercise
    var sets: [WorkoutSet]
    
    init(id: UUID = UUID(), exercise: Exercise, sets: [WorkoutSet] = []) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
    }
}

struct WorkoutTemplate: Identifiable, Codable {
    let id: UUID
    let name: String
    let exercises: [Exercise]
    
    init(id: UUID = UUID(), name: String, exercises: [Exercise]) {
        self.id = id
        self.name = name
        self.exercises = exercises
    }
}

struct ActiveWorkout: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    var exercises: [WorkoutExercise]
    
    init(id: UUID = UUID(), startTime: Date = Date(), endTime: Date? = nil, exercises: [WorkoutExercise] = []) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.exercises = exercises
    }
} 