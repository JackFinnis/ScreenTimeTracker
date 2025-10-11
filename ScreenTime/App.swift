//
//  ScreenTimeApp.swift
//  ScreenTime
//
//  Created by Jack Finnis on 05/03/2024.
//

import SwiftUI
import DeviceActivity
import FamilyControls
import StoreKit

// Screen time by hour of day not app

@main
struct ScreenTimeApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @Environment(\.requestReview) var requestReview
    @State var productiveActivities = FileStore.get(key: .productiveActivities) ?? FamilyActivitySelection(includeEntireCategory: true)
    @State var blockedActivities = FileStore.get(key: .blockedActivities) ?? FamilyActivitySelection(includeEntireCategory: true)
    @State var showProductivePicker = false
    @State var showBlockedPicker = false
    
    var body: some View {
        NavigationStack {
            DeviceActivityReport(
                .activity,
                filter: DeviceActivityFilter(
                    segment: .daily(
                        during: DateInterval(
                            start: .distantPast,
                            end: .distantFuture
                        )
                    )
                )
            )
            .ignoresSafeArea(edges: .bottom)
            .background {
                ProgressView()
                    .controlSize(.large)
            }
            .navigationTitle("Screen Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarTitleMenu {
                Button {
                    requestReview()
                } label: {
                    Label("Rate Screen Time", systemImage: "star")
                }
                Link(destination: URL(string: "mailto:jack@jackfinnis.com?subject=Screen%20TimeFeedback")!) {
                    Label("Improve Screen Time", systemImage: "envelope")
                }
            }
            .toolbarBackground(.visible, for: .bottomBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu("Edit") {
                        Section("Mark apps or websites as productive to help you decrease your unproductive screen time.") {
                            Button("Choose Productive Apps") {
                                showProductivePicker = true
                            }
                        }
                        Section("Block apps or websites that you want to stop using completely.") {
                            Button("Choose Blocked Apps") {
                                showBlockedPicker = true
                            }
                        }
                    }
                }
            }
        }
        .familyActivityPicker(headerText: "Choose Productive Apps", isPresented: $showProductivePicker, selection: $productiveActivities)
        .familyActivityPicker(headerText: "Choose Blocked Apps", isPresented: $showBlockedPicker, selection: $blockedActivities)
        .sensoryFeedback(.impact, trigger: productiveActivities)
        .sensoryFeedback(.impact, trigger: blockedActivities)
        .onChange(of: productiveActivities) { _, productiveActivities in
            FileStore.set(key: .productiveActivities, value: productiveActivities)
        }
        .onChange(of: blockedActivities) { _, blockedActivities in
            FileStore.set(key: .blockedActivities, value: blockedActivities)
            ActivityMonitor().blockActivities()
        }
        .task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                ActivityMonitor().reset()
            } catch {
                print(error)
            }
        }
    }
}
