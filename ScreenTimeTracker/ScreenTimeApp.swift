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
    @State var weeksAgo = 0
    
    var body: some View {
        let end = Calendar.current.date(byAdding: .day, value: weeksAgo * -7, to: .now)!
        let start = Calendar.current.date(byAdding: .day, value: -6, to: end)!
        var title: String {
            let end = end.formatted(Date.FormatStyle().day().month())
            let start = start.formatted(Date.FormatStyle().day().month())
            return "\(start) to \(end)"
        }
        
        NavigationStack {
            DeviceActivityReport(
                .activity,
                filter: DeviceActivityFilter(
                    segment: .daily(during: DateInterval(start: start, end: end))
                )
            )
            .ignoresSafeArea(edges: .bottom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Button {
                            if weeksAgo < 3 {
                                weeksAgo += 1
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        .disabled(weeksAgo == 3)
                        .fixedSize()
                        
                        Text(title)
                            .frame(width: 150)
                            .monospacedDigit()
                        
                        Button {
                            if weeksAgo > 0 {
                                weeksAgo -= 1
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                        .disabled(weeksAgo == 0)
                        .fixedSize()
                    }
                    .font(.headline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        showActivityPicker = true
                    }
                }
            }
            .background {
                ProgressView()
                    .controlSize(.large)
            }
        }
        .sensoryFeedback(.impact, trigger: productiveActivities)
        .familyActivityPicker(headerText: "Select Productive Apps", isPresented: $showActivityPicker, selection: $productiveActivities)
        .task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            } catch {
                print(error)
            }
        }
    }
}
