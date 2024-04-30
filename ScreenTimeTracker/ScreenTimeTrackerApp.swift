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
struct ScreenTimeTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ReportView()
        }
    }
}

struct ReportView: View {
    var body: some View {
        DeviceActivityReport(
            .totalActivity,
            filter: DeviceActivityFilter(segment: .daily(during: DateInterval(start: .distantPast, end: .distantFuture)))
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
