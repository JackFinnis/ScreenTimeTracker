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
    @Environment(\.scenePhase) var scenePhase
    @AppStorage("featuresUsed") var featuresUsed = 0
    @State var productiveActivities = FileStore.get(key: .productiveActivities) ?? FamilyActivitySelection(includeEntireCategory: true)
    @State var blockedActivities = FileStore.get(key: .blockedActivities) ?? FamilyActivitySelection(includeEntireCategory: true)
    @State var showProductivePicker = false
    @State var showBlockedPicker = false
    
    var body: some View {
        let productive = productiveActivities.applications.count + productiveActivities.webDomains.count
        let blocked = blockedActivities.applications.count + blockedActivities.webDomains.count
        
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
            .navigationSubtitle("\(productive) Productive • \(blocked) Blocked")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarTitleMenu {
                Section("Screen Time") {
                    Button {
                        requestReview()
                    } label: {
                        Label("Rate Screen Time", systemImage: "star")
                    }
                    Link(destination: URL(string: "https://apps.apple.com/app/id6738397686?action=write-review")!) {
                        Label("Write a Review", systemImage: "quote.bubble")
                    }
                    Link(destination: URL(string: "mailto:jack@jackfinnis.com?subject=Screen%20Time%20Feedback")!) {
                        Label("Send Feedback", systemImage: "envelope")
                    }
                    Link(destination: URL(string: "https://apps.apple.com/developer/1633101066")!) {
                        Label("More Apps by Jack", systemImage: "square.grid.2x2")
                    }
                }
            }
            .toolbarBackground(.visible, for: .bottomBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu("Edit") {
                        Section("Mark apps as productive to help you identify your unproductive screen time.") {
                            Button("Choose Productive Apps") {
                                showProductivePicker = true
                            }
                        }
                        Section("Block apps and websites that you want to stop using completely.") {
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
        .onChange(of: scenePhase) { _, _ in
            switch scenePhase {
            case .active:
                featuresUsed += 1
            default: break
            }
        }
        .onChange(of: featuresUsed) { _, _ in
            if featuresUsed.isMultiple(of: 10) {
                requestReview()
            }
        }
    }
}
