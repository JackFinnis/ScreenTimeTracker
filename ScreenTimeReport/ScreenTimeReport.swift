//
//  ScreenTimeReportExtension.swift
//  ScreenTimeTracker
//
//  Created by Jack Finnis on 05/10/2024.
//

import DeviceActivity
import SwiftUI
import Charts
import FamilyControls
import ManagedSettings

@main
struct ScreenTimeReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        ActivityReportScene { days in
            ActivityReportView(days: days)
        }
    }
}

struct Day: Identifiable, Equatable {
    let dateInterval: DateInterval
    let totalActivity: Double
    let apps: [App]
    
    var id: Date { dateInterval.start }
}

struct App: Identifiable, Equatable {
    let name: String
    let bundleIdentifier: String
    let token: ApplicationToken
    let totalActivity: Double
    
    var id: String { bundleIdentifier }
}

struct ActivityReportScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .activity
    let content: ([Day]) -> ActivityReportView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> [Day] {
        var days: [Day] = []
        for await activity in data {
            for await segment in activity.activitySegments {
                var apps: [App] = []
                for await category in segment.categories {
                    for await application in category.applications {
                        guard let token = application.application.token,
                              let name = application.application.localizedDisplayName,
                              let bundleIdentifier = application.application.bundleIdentifier
                        else { continue }
                        apps.append(App(name: name, bundleIdentifier: bundleIdentifier, token: token, totalActivity: application.totalActivityDuration))
                    }
                }
                days.append(Day(dateInterval: segment.dateInterval, totalActivity: segment.totalActivityDuration, apps: apps.sorted(using: SortDescriptor(\.totalActivity, order: .reverse))))
            }
        }
        return days
    }
}

struct ActivityReportView: View {
    let days: [Day]
    
    @AppState("productiveActivities") var productiveActivities = FamilyActivitySelection(includeEntireCategory: true)
    @State var selectedDay: Day?
    
    func isProductive(_ app: App) -> Bool {
        productiveActivities.applicationTokens.contains(app.token)
        || app.bundleIdentifier.starts(with: "com.jackfinnis")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Chart {
                ForEach(days) { day in
                    let selected = day == selectedDay
                    let color: Color = selected ? .orange : .indigo
                    let productiveApps = day.apps.filter { isProductive($0) }
                    let unproductiveApps = day.apps.filter { !isProductive($0) }
                    let productiveActivity = productiveApps.map(\.totalActivity).sum()
                    let unproductiveActivity = unproductiveApps.map(\.totalActivity).sum()
                    
                    BarMark(
                        x: .value("Day", day.dateInterval.start, unit: .day),
                        y: .value("Unproductive Activity", unproductiveActivity)
                    )
                    .foregroundStyle(color)
                    
                    BarMark(
                        x: .value("Day", day.dateInterval.start, unit: .day),
                        y: .value("Productive Activity", productiveActivity)
                    )
                    .foregroundStyle(color.opacity(0.5))
                }
                
                let averageActivity = days.map(\.totalActivity).average()
                let averageUnproductiveActivity = days.map { $0.apps.filter { !isProductive($0) }.map(\.totalActivity).sum() }.average()
                
                RuleMark(
                    y: .value("Average Activity", averageActivity)
                )
                .foregroundStyle(.orange.opacity(0.5))
                
                RuleMark(
                    y: .value("Average Unproductive Activity", averageUnproductiveActivity)
                )
                .foregroundStyle(.orange)
            }
            .chartYAxis {
                AxisMarks(preset: .aligned, values: .stride(by: 3600)) { value in
                    AxisValueLabel(String(value.index))
                    AxisGridLine()
                }
            }
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .stride(by: .day)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel(date.day, centered: true)
                    }
                }
            }
            .chartXSelection(value: .init(get: {
                selectedDay?.dateInterval.start
            }, set: { date in
                if let date {
                    selectedDay = days.first { $0.dateInterval.contains(date) }
                }
            }))
            .padding(.vertical, 5)
            .frame(height: 250)
            
            Divider()
            List {
                if let selectedDay {
                    let maxActivity = selectedDay.apps.first?.totalActivity ?? 1
                    ForEach(selectedDay.apps) { app in
                        if app.totalActivity > 60 {
                            Text(app.name)
                                .badge(Duration.seconds(app.totalActivity).formatted(Duration.UnitsFormatStyle(allowedUnits: [.hours, .minutes], width: .narrow)))
                                .listRowBackground(
                                    GeometryReader { geo in
                                        HStack(spacing: 0) {
                                            Color.orange.opacity(isProductive(app) ? 0.15 : 0.3)
                                                .frame(width: geo.size.width * app.totalActivity / maxActivity)
                                            Color.clear
                                        }
                                    }
                                )
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .background(.background)
    }
}
