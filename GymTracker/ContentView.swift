//
//  ContentView.swift
//  GymTracker
//
//  Created by Gökay Karaahmetli on 15.12.24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
            
            WorkoutView()
                .tabItem {
                    Label("Training", systemImage: "figure.strengthtraining.traditional")
                }
            
            HistoryView()
                .tabItem {
                    Label("Verlauf", systemImage: "clock.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutStore())
}
