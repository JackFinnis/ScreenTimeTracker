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
    var body: some View {
        DeviceActivityReport(
            .activity,
            filter: DeviceActivityFilter(segment: .daily(during: DateInterval(start: Calendar.current.date(byAdding: .day, value: -14, to: .now)!, end: .now)))
        )
        .background {
            ProgressView()
                .controlSize(.large)
        }
        .ignoresSafeArea()
        .task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            } catch {
                print(error)
            }
        }
    }
}
