//
//  ScreenTimeTrackerApp.swift
//  ScreenTimeTracker
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

enum Device: String, CaseIterable {
    case iPhone
    case iPad
    case mac = "Mac"
    
    var model: DeviceActivityData.Device.Model {
        switch self {
        case .iPhone:
            return .iPhone
        case .iPad:
            return .iPad
        case .mac:
            return .mac
        }
    }
    
    var systemImage: String {
        switch self {
        case .iPhone:
            return "iphone"
        case .iPad:
            return "ipad"
        case .mac:
            return "macbook"
        }
    }
}

struct RootView: View {
    @Environment(\.requestReview) var requestReview
    @AppState(.productiveActivities) var productiveActivities = FamilyActivitySelection(includeEntireCategory: true)
    @State var showActivityPicker = false
    @State var weeksAgo = 0
    @State var device: Device = .iPhone
    
    var body: some View {
        let end = Calendar.current.date(byAdding: .day, value: weeksAgo * -7, to: .now)!
        let start = Calendar.current.date(byAdding: .day, value: -6, to: end)!
        var title: String {
            let end = end.formatted(Date.FormatStyle().weekday().day().month())
            let start = start.formatted(Date.FormatStyle().weekday().day().month())
            return "\(start) - \(end)"
        }
        
        NavigationStack {
            DeviceActivityReport(
                .activity,
                filter: DeviceActivityFilter(
                    segment: .daily(during: DateInterval(start: start, end: end)),
                    devices: .init([device.model])
                )
            )
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Screen Time")
            .navigationBarTitleDisplayMode(.inline)
            .contentMargins(.top, 5)
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
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Device", selection: $device) {
                            ForEach(Device.allCases, id: \.self) { device in
                                Label(device.rawValue, systemImage: device.systemImage)
                            }
                        }
                    } label: {
                        Label(device.rawValue, systemImage: device.systemImage)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showActivityPicker = true
                    } label: {
                        Label("Select Productive Apps", systemImage: "checklist")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        if weeksAgo < 3 {
                            weeksAgo += 1
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(weeksAgo == 3)
                    .font(.headline)
                }
                ToolbarItem(placement: .status) {
                    Text(title)
                        .fixedSize()
                        .monospacedDigit()
                }
                .sharedBackgroundVisibility(.hidden)
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        if weeksAgo > 0 {
                            weeksAgo -= 1
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(weeksAgo == 0)
                    .font(.headline)
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
