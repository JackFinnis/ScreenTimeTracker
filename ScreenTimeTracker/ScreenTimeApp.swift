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
            filter: DeviceActivityFilter(segment: .daily(during: DateInterval(start: .distantPast, end: .distantFuture)))
        )
//        DeviceActivityReport(
//            .sleep,
//            filter: DeviceActivityFilter(segment: .hourly(during: .init(start: .distantPast, end: .distantFuture)))
//        )
//        .preferredColorScheme(.dark)
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

#Preview {
    RootView()
}
