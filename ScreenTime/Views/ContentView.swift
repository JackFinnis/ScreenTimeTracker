//
//  ContentView.swift
//  ScreenTime
//
//  Created by Jack Finnis on 07/03/2026.
//

import SwiftUI
import DeviceActivity
import FamilyControls
import StoreKit

struct ContentView: View {
    @Environment(\.requestReview) var requestReview
    @Environment(\.scenePhase) var scenePhase
    @AppStorage("featuresUsed") var featuresUsed = 0
    @State var productiveActivities = FileStore.get(key: .productiveActivities) ?? FamilyActivitySelection(includeEntireCategory: true)
    @State var blockedActivities = FileStore.get(key: .blockedActivities) ?? FamilyActivitySelection(includeEntireCategory: true)
    @State var bannedActivities = FileStore.get(key: .bannedActivities) ?? FamilyActivitySelection(includeEntireCategory: true)
    @State var showProductivePicker = false
    @State var showBlockedPicker = false
    @State var showBannedPicker = false
    @State var showShareSheet = false

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
                Section("Screen Time") {
                    Button {
                        showShareSheet = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    Link(destination: URL(string: "https://jackfinnis.com/apps/screen-time")!) {
                        Label("Get Help", systemImage: "questionmark.circle")
                    }
                    Link(destination: URL(string: "mailto:jack@jackfinnis.com?subject=Screen%20Time%20Feedback")!) {
                        Label("Send Feedback", systemImage: "envelope")
                    }
                    Link(destination: URL(string: "https://apps.apple.com/app/id6738397686?action=write-review")!) {
                        Label("Write a Review", systemImage: "star")
                    }
                    Link(destination: URL(string: "https://apps.apple.com/developer/1633101066")!) {
                        Label("More Apps", systemImage: "square.grid.2x2")
                    }
                }
            }
            .toolbarBackground(.visible, for: .bottomBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("Mark apps as productive to help you identify your unproductive screen time.") {
                            Button {
                                showProductivePicker = true
                            } label: {
                                Text("Choose Productive Apps")
                                Text("\(productiveActivities.applications.count.formatted(singular: "App")), \(productiveActivities.webDomains.count.formatted(singular: "Website"))")
                            }
                        }
                        Section("Restrict apps you want to stop using. Restricted apps can't be edited from 10pm to 8am.") {
                            Button {
                                showBlockedPicker = true
                            } label: {
                                Text("Choose Restricted Apps")
                                Text("\(blockedActivities.applications.count.formatted(singular: "App")), \(blockedActivities.webDomains.count.formatted(singular: "Website"))")
                            }
                            .disabled(Date.now.isNight)
                        }
                        Section("Block apps to completely block them at all times. Blocked apps can't be edited from 10pm to 8am.") {
                            Button {
                                showBannedPicker = true
                            } label: {
                                Text("Choose Blocked Apps")
                                Text("\(bannedActivities.applications.count.formatted(singular: "App")), \(bannedActivities.webDomains.count.formatted(singular: "Website"))")
                            }
                            .disabled(Date.now.isNight)
                        }
                    } label: {
                        Label("Filter Screen Time", systemImage: "line.3.horizontal.decrease")
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [URL(string: "https://apps.apple.com/app/id6738397686")!])
                .presentationDetents([.medium])
        }
        .familyActivityPicker(headerText: "Choose Productive Apps", isPresented: $showProductivePicker, selection: $productiveActivities)
        .familyActivityPicker(headerText: "Choose Restricted Apps", isPresented: $showBlockedPicker, selection: $blockedActivities)
        .familyActivityPicker(headerText: "Choose Blocked Apps", isPresented: $showBannedPicker, selection: $bannedActivities)
        .sensoryFeedback(.impact, trigger: productiveActivities)
        .sensoryFeedback(.impact, trigger: blockedActivities)
        .sensoryFeedback(.impact, trigger: bannedActivities)
        .onChange(of: productiveActivities) { _, productiveActivities in
            FileStore.set(key: .productiveActivities, value: productiveActivities)
        }
        .onChange(of: blockedActivities) { _, blockedActivities in
            FileStore.set(key: .blockedActivities, value: blockedActivities)
            ActivityMonitor().blockActivities()
        }
        .onChange(of: bannedActivities) { _, bannedActivities in
            FileStore.set(key: .bannedActivities, value: bannedActivities)
            ActivityMonitor().banActivities()
        }
        .task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            } catch {
                print(error)
            }
        }
        .onChange(of: scenePhase) { _, _ in
            switch scenePhase {
            case .active:
                featuresUsed += 1
                ActivityMonitor().reset()
            default: break
            }
        }
        .onChange(of: featuresUsed) { _, _ in
            if featuresUsed.isMultiple(of: 20) {
                requestReview()
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
