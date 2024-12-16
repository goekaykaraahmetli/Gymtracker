import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text("Verlauf").tag(0)
                    Text("Bestleistungen").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if selectedTab == 0 {
                    WorkoutHistoryList(workouts: workoutStore.workoutHistory)
                } else {
                    PersonalRecordsList(records: Array(workoutStore.personalRecords.values))
                }
            }
            .navigationTitle("Verlauf")
        }
    }
}

struct WorkoutHistoryList: View {
    let workouts: [WorkoutHistory]
    
    var groupedWorkouts: [(String, [WorkoutHistory])] {
        let grouped = Dictionary(grouping: workouts) { workout in
            Calendar.current.startOfDay(for: workout.date)
        }
        return grouped.map { (date, workouts) in
            (date.formatted(date: .abbreviated, time: .omitted), workouts)
        }.sorted { $0.0 > $1.0 }
    }
    
    var body: some View {
        if workouts.isEmpty {
            ContentUnavailableView(
                "Keine Trainings",
                systemImage: "figure.run",
                description: Text("Starte dein erstes Training um deinen Fortschritt zu sehen")
            )
        } else {
            List {
                ForEach(groupedWorkouts, id: \.0) { date, workouts in
                    Section(date) {
                        ForEach(workouts) { workout in
                            NavigationLink {
                                WorkoutDetailView(workout: workout)
                            } label: {
                                WorkoutHistoryRow(workout: workout)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct WorkoutHistoryRow: View {
    let workout: WorkoutHistory
    
    var totalVolume: Int {
        workout.exercises.reduce(0) { total, exercise in
            total + exercise.sets.reduce(0) { setTotal, set in
                setTotal + Int(Double(set.reps) * set.weight)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(workout.templateName)
                .font(.headline)
            
            HStack {
                Text(workout.date.formatted(date: .omitted, time: .shortened))
                Text("•")
                Text("\(workout.exercises.count) Übungen")
                Text("•")
                Text("\(totalVolume)kg Total")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct PersonalRecordsList: View {
    let records: [PersonalRecord]
    @State private var selectedMuscleGroup: MuscleGroup?
    
    var filteredRecords: [PersonalRecord] {
        guard let muscleGroup = selectedMuscleGroup else {
            return records
        }
        return records.filter { $0.exercise.muscleGroup == muscleGroup }
    }
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "Alle",
                        isSelected: selectedMuscleGroup == nil,
                        action: { selectedMuscleGroup = nil }
                    )
                    
                    ForEach(MuscleGroup.allCases, id: \.self) { group in
                        FilterChip(
                            title: group.rawValue,
                            isSelected: selectedMuscleGroup == group,
                            action: { selectedMuscleGroup = group }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            if records.isEmpty {
                ContentUnavailableView(
                    "Keine Bestleistungen",
                    systemImage: "trophy",
                    description: Text("Trainiere um deine Bestleistungen zu sehen")
                )
            } else {
                List {
                    ForEach(filteredRecords) { record in
                        PersonalRecordRow(record: record)
                    }
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}

struct PersonalRecordRow: View {
    let record: PersonalRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(record.exercise.name)
                        .font(.headline)
                    Text(record.exercise.equipment.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 16) {
                PRMetric(
                    title: "Max Gewicht",
                    value: "\(Int(record.maxWeight))kg",
                    icon: "scalemass"
                )
                
                PRMetric(
                    title: "Max Wiederholungen",
                    value: "\(record.maxReps) Wdh",
                    icon: "repeat"
                )
                
                PRMetric(
                    title: "Bester Satz",
                    value: "\(record.maxVolumeSet.reps) × \(Int(record.maxVolumeSet.weight))kg",
                    icon: "chart.bar.fill"
                )
            }
        }
        .padding(.vertical, 4)
    }
}

struct PRMetric: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline.bold())
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(WorkoutStore())
} 