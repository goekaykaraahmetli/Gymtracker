import Foundation

struct WorkoutHistory: Identifiable, Codable {
    let id: UUID
    let templateName: String
    let date: Date
    let exercises: [CompletedExercise]
    
    init(id: UUID = UUID(), templateName: String, date: Date = Date(), exercises: [CompletedExercise]) {
        self.id = id
        self.templateName = templateName
        self.date = date
        self.exercises = exercises
    }
}

struct CompletedExercise: Identifiable, Codable {
    let id: UUID
    let exercise: Exercise
    let sets: [CompletedSet]
    
    init(id: UUID = UUID(), exercise: Exercise, sets: [CompletedSet]) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
    }
}

struct CompletedSet: Identifiable, Codable {
    let id: UUID
    let reps: Int
    let weight: Double
    
    init(id: UUID = UUID(), reps: Int, weight: Double) {
        self.id = id
        self.reps = reps
        self.weight = weight
    }
}

struct PersonalRecord: Identifiable, Codable {
    let id: UUID
    let exercise: Exercise
    let date: Date
    let maxWeight: Double      // For 1RM
    let maxReps: Int          // Max reps at any weight
    let maxVolumeSet: (reps: Int, weight: Double) // Best set by volume (reps × weight)
    
    private enum CodingKeys: String, CodingKey {
        case id, exercise, date, maxWeight, maxReps
        case volumeSetReps, volumeSetWeight
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        exercise = try container.decode(Exercise.self, forKey: .exercise)
        date = try container.decode(Date.self, forKey: .date)
        maxWeight = try container.decode(Double.self, forKey: .maxWeight)
        maxReps = try container.decode(Int.self, forKey: .maxReps)
        
        // Decode tuple components separately
        let reps = try container.decode(Int.self, forKey: .volumeSetReps)
        let weight = try container.decode(Double.self, forKey: .volumeSetWeight)
        maxVolumeSet = (reps: reps, weight: weight)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(exercise, forKey: .exercise)
        try container.encode(date, forKey: .date)
        try container.encode(maxWeight, forKey: .maxWeight)
        try container.encode(maxReps, forKey: .maxReps)
        
        // Encode tuple components separately
        try container.encode(maxVolumeSet.reps, forKey: .volumeSetReps)
        try container.encode(maxVolumeSet.weight, forKey: .volumeSetWeight)
    }
    
    init(id: UUID = UUID(), exercise: Exercise, date: Date, maxWeight: Double, maxReps: Int, maxVolumeSet: (reps: Int, weight: Double)) {
        self.id = id
        self.exercise = exercise
        self.date = date
        self.maxWeight = maxWeight
        self.maxReps = maxReps
        self.maxVolumeSet = maxVolumeSet
    }
} 