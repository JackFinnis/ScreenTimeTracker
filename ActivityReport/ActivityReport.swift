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
            ActivityReportView(report: report)
        }
    }
}

struct Report {
    let days: [Day]
}

struct Day: Identifiable, Equatable {
    var id: Date { interval.start }
    let interval: DateInterval
    let activities: [Activity]
}

struct Activity: Identifiable, Equatable {
    let id: String
    let name: String
    let duration: Double
    let appToken: ApplicationToken?
    let webToken: WebDomainToken?
}

extension Array where Element == Activity {
    var totalDuration: Double {
        map(\.duration).sum()
    }
}

func getActivityType(_ activity: Activity, productive: FamilyActivitySelection, blocked: FamilyActivitySelection) -> ActivityType {
    if let appToken = activity.appToken {
        if blocked.applicationTokens.contains(appToken) {
            return .blocked
        } else if productive.applicationTokens.contains(appToken) {
            return .productive
        }
    } else if let webToken = activity.webToken {
        if blocked.webDomainTokens.contains(webToken) {
            return .blocked
        } else if productive.webDomainTokens.contains(webToken) {
            return .productive
        }
    }
    return .unproductive
}

struct ActivityReportScene: DeviceActivityReportScene {
    let content: (Report) -> ActivityReportView
    
    let context: DeviceActivityReport.Context = .activity
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> Report {
        var days: [Day] = []
        for await activity in data {
            for await segment in activity.activitySegments {
                guard segment.dateInterval.start == segment.dateInterval.start.startOfDay else { continue }
                
                var activities: [Activity] = []
                
                for await category in segment.categories {
                    for await app in category.applications {
                        guard let token = app.application.token,
                              let name = app.application.localizedDisplayName,
                              let bundleID = app.application.bundleIdentifier
                        else { continue }
                        activities.append(Activity(id: bundleID, name: name, duration: app.totalActivityDuration, appToken: token, webToken: nil))
                    }
                    for await web in category.webDomains {
                        guard let token = web.webDomain.token,
                              let domain = web.webDomain.domain
                        else { continue }
                        activities.append(Activity(id: domain, name: domain, duration: web.totalActivityDuration, appToken: nil, webToken: token))
                    }
                }
                
                days.append(Day(interval: segment.dateInterval, activities: activities))
            }
        }
        return Report(days: days)
    }
}

struct ActivityReportView: View {
    let report: Report
    
    @State var selectedDate = Date.now
    
    var body: some View {
        let days = report.days
        let productiveActivities: FamilyActivitySelection = FileStore.get(key: .productiveActivities) ?? .init()
        let blockedActivities: FamilyActivitySelection = FileStore.get(key: .blockedActivities) ?? .init()
        
        VStack(spacing: 0) {
            Chart {
                ForEach(days) { day in
                    ForEach(ActivityType.allCases, id: \.self) { type in
                        let activities = day.activities.filter { getActivityType($0, productive: productiveActivities, blocked: blockedActivities) == type }
                        BarMark(
                            x: .value("Day", day.interval.start, unit: .day),
                            y: .value("Duration", activities.totalDuration)
                        )
                        .foregroundStyle(type.color.opacity(day.interval.start == selectedDate.startOfDay ? 1 : 0.5))
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
            .chartXSelection(value: Binding {
                selectedDate as Date?
            } set: { date in
                if let date {
                    selectedDate = date
                }
            })
            .padding(.horizontal)
            .padding(.top, 5)
            .frame(height: 250)
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(days) { day in
                        let maxActivity = day.activities.map(\.duration).max() ?? 1

                        VStack(spacing: 0) {
                            HStack {
                                Text(day.id.formatted(Date.FormatStyle().weekday().day().month()))
                                    .font(.headline)
                                Spacer()
                                Text(day.activities.totalDuration.formattedDuration)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            Divider()
                            List {
                                ForEach(ActivityType.allCases, id: \.self) { type in
                                    let activities = day.activities
                                        .filter { getActivityType($0, productive: productiveActivities, blocked: blockedActivities) == type && $0.duration > 60 }
                                        .sorted(using: SortDescriptor(\.duration, order: .reverse))
                                    if activities.isNotEmpty {
                                        Section {
                                            ForEach(activities) { activity in
                                                Text(activity.name)
                                                    .badge(activity.duration.formattedDuration)
                                                    .listRowBackground(
                                                        GeometryReader { geo in
                                                            HStack(spacing: 0) {
                                                                type.color.opacity(0.5)
                                                                    .frame(width: geo.size.width * activity.duration / maxActivity)
                                                                Rectangle().fill(Color(.secondarySystemGroupedBackground))
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
                            .listStyle(.plain)
                            .contentMargins(.top, 10)
                        }
                        .containerRelativeFrame(.horizontal)
                        .id(day.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: Binding {
                selectedDate.startOfDay as Date?
            } set: { date in
                if let date {
                    selectedDate = date
                }
            })
        }
        .background(.background)
    }
}
