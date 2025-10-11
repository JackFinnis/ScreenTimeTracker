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
struct ActivityReport: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        ActivityReportScene { report in
            ActivityReportWrapper(report: report)
        }
    }
}

struct Report {
    let model: DeviceActivityData.Device.Model
    let date: Date
    let days: [Day]
}

struct Day: Identifiable, Equatable {
    var id: Date { interval.start }
    let interval: DateInterval
    let activities: [Activity]
}

struct Activity: Identifiable, Equatable {
    let id: String
    let type: ActivityType
    let name: String
    let duration: Double
}

extension Array where Element == Activity {
    var totalDuration: Double {
        map(\.duration).sum()
    }
}

struct ActivityReportScene: DeviceActivityReportScene {
    let content: (Report) -> ActivityReportWrapper
    
    let context: DeviceActivityReport.Context = .activity
    let productiveActivities: FamilyActivitySelection = FileStore.get(key: .productiveActivities) ?? .init()
    let blockedActivities: FamilyActivitySelection = FileStore.get(key: .blockedActivities) ?? .init()
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> Report {
        var days: [Day] = []
        var model: DeviceActivityData.Device.Model = .iPhone
        for await activity in data {
            model = activity.device.model
            for await segment in activity.activitySegments {
                var activities: [Activity] = []
                
                for await category in segment.categories {
                    for await app in category.applications {
                        guard let token = app.application.token,
                              let name = app.application.localizedDisplayName,
                              let bundleID = app.application.bundleIdentifier
                        else { continue }
                        let type: ActivityType
                        if blockedActivities.applicationTokens.contains(token) {
                            type = .blocked
                        } else if productiveActivities.applicationTokens.contains(token) || bundleID.starts(with: "com.jackfinnis") {
                            type = .productive
                        } else {
                            type = .unproductive
                        }
                        activities.append(Activity(id: bundleID, type: type, name: name, duration: app.totalActivityDuration))
                    }
                    for await web in category.webDomains {
                        guard let token = web.webDomain.token,
                              let domain = web.webDomain.domain
                        else { continue }
                        let type: ActivityType
                        if blockedActivities.webDomainTokens.contains(token) {
                            type = .blocked
                        } else if productiveActivities.webDomainTokens.contains(token) || domain == "jackfinnis.com" {
                            type = .productive
                        } else {
                            type = .unproductive
                        }
                        activities.append(Activity(id: domain, type: type, name: domain, duration: web.totalActivityDuration))
                    }
                }
                
                days.append(Day(interval: segment.dateInterval, activities: activities))
            }
        }
        let date = days.first?.interval.start ?? .now
        return Report(model: model, date: date, days: days)
    }
}

struct ActivityReportWrapper: View {
    let report: Report
    
    var body: some View {
        ActivityReportView(days: report.days)
            .id(report.model)
            .id(report.date)
    }
}

struct ActivityReportView: View {
    let days: [Day]
    
    @State var selectedDay: Day?
    
    var body: some View {
        VStack(spacing: 0) {
            Chart {
                ForEach(days) { day in
                    ForEach(ActivityType.allCases, id: \.self) { type in
                        BarMark(
                            x: .value("Day", day.interval.start, unit: .day),
                            y: .value("Duration", day.activities.filter { $0.type == type }.totalDuration)
                        )
                        .foregroundStyle(type.color.opacity(day == selectedDay ? 1 : 0.5))
                    }
                }
            }
            .chartYAxis {
                AxisMarks(preset: .aligned, values: .stride(by: oneHour)) { value in
                    AxisGridLine()
                    if value.index == 0 {
                        AxisValueLabel("0")
                    } else if value.index.isMultiple(of: 2) {
                        AxisValueLabel("\(value.index)h")
                    }
                }
            }
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .stride(by: .day)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel(String(date.formatted(Date.FormatStyle().weekday()).first!), centered: true)
                    }
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: oneDay*7)
            .chartScrollPosition(initialX: Date.now)
            .chartScrollTargetBehavior(
                .valueAligned(
                    matching: DateComponents(hour: 0),
                    majorAlignment: .matching(DateComponents(day: 1)),
                )
            )
            .chartXSelection(value: .init {
                selectedDay?.interval.start
            } set: { date in
                if let date {
                    selectedDay = days.first { $0.interval.contains(date) }
                }
            })
            .padding(.top, 5)
            .padding(.horizontal)
            .frame(height: 250)
            
            if let selectedDay {
                let maxActivity = selectedDay.activities.map(\.duration).max() ?? 1
                
                HStack {
                    Text(selectedDay.id.formatted(Date.FormatStyle().weekday().day().month()))
                        .font(.headline)
                    Spacer()
                    Text(selectedDay.activities.totalDuration.formattedDuration)
                        .foregroundStyle(.secondary)
                }
                .padding()
                Divider()
                List {
                    ForEach(ActivityType.allCases, id: \.self) { type in
                        let activities = selectedDay.activities
                            .filter { $0.type == type && $0.duration > 60 }
                            .sorted(using: SortDescriptor(\.duration, order: .reverse))
                        if activities.isNotEmpty {
                            Section {
                                ForEach(activities) { activity in
                                    Text(activity.name)
                                        .badge(activity.duration.formattedDuration)
                                        .listRowBackground(
                                            GeometryReader { geo in
                                                HStack(spacing: 0) {
                                                    activity.type.color.opacity(0.5)
                                                        .frame(width: geo.size.width * activity.duration / maxActivity)
                                                    Rectangle().fill(.background)
                                                }
                                            }
                                        )
                                }
                            } header: {
                                HStack {
                                    Text(type.name)
                                        .font(.headline)
                                    Spacer()
                                    Text(activities.totalDuration.formattedDuration)
                                        .foregroundStyle(.secondary)
                                }
                                .font(.body)
                            }
                            .headerProminence(.increased)
                        }
                    }
                }
                .contentMargins(.top, 10)
            } else {
                Spacer()
            }
        }
        .onAppear {
            selectedDay = days.last
        }
    }
}
