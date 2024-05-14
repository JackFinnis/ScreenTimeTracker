//
//  RootView.swift
//  ScreenTimeTracker
//
//  Created by Jack Finnis on 14/05/2024.
//

import SwiftUI
import DeviceActivity
import FamilyControls

struct RootView: View {
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

#Preview {
    RootView()
}
