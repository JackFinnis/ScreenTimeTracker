//
//  ScreenTimeTrackerApp.swift
//  ScreenTimeTracker
//
//  Created by Jack Finnis on 05/03/2024.
//

import SwiftUI
import DeviceActivity
import FamilyControls
import Charts

@main
struct ScreenTimeTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    var body: some View {
        NavigationStack {
            DeviceActivityReport(
                .totalActivity,
                filter: DeviceActivityFilter(segment: .daily(during: DateInterval(start: .distantPast, end: .distantFuture)))
            )
            .navigationTitle("Screen Time")
        }
        .task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            } catch {
                print(error)
            }
        }
    }
}
