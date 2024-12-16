//
//  GymTrackerApp.swift
//  GymTracker
//
//  Created by Gökay Karaahmetli on 15.12.24.
//

import SwiftUI

@main
struct GymTrackerApp: App {
    @StateObject private var workoutStore = WorkoutStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutStore)
        }
    }
}
