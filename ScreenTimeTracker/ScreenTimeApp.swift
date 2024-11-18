//
//  ScreenTimeTrackerApp.swift
//  ScreenTimeTracker
//
//  Created by Jack Finnis on 05/03/2024.
//

import SwiftUI
import DeviceActivity
import FamilyControls

@main
struct ScreenTimeApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @AppState("productiveActivities") var productiveActivities = FamilyActivitySelection(includeEntireCategory: true)
    @State var showActivityPicker = false
    
    var body: some View {
        NavigationStack {
            DeviceActivityReport(
                .activity,
                filter: DeviceActivityFilter(
                    segment: .daily(during: DateInterval(start: Calendar.current.date(byAdding: .day, value: -6, to: .now)!, end: .now))
                )
            )
            .ignoresSafeArea(edges: .bottom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Screen Time")
                        .font(.headline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Productive Apps") {
                        showActivityPicker = true
                    }
                    .font(.headline)
                }
            }
            .background {
                ProgressView()
                    .controlSize(.large)
            }
        }
        .sensoryFeedback(.impact, trigger: productiveActivities)
        .familyActivityPicker(isPresented: $showActivityPicker, selection: $productiveActivities)
        .task {
            print(Calendar.current.veryShortWeekdaySymbols)
            print(Calendar.current.component(.weekday, from: .now))
            print(Date.now.day)
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            } catch {
                print(error)
            }
        }
    }
}
