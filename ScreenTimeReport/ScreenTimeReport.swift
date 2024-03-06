//
//  ScreenTimeReport.swift
//  ScreenTimeReport
//
//  Created by Jack Finnis on 05/03/2024.
//

import DeviceActivity
import SwiftUI
import Charts

@main
struct ScreenTimeReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        ScreenTimeReportScene { days in
            ScreenTimeReport(days: days)
        }
    }
}

let oneHour = 3600.0
let oneDay = 24 * oneHour

struct ScreenTimeReport: View {
    @State var selectedDay: Day?
    
    let days: [Day]
    
    var body: some View {
        VStack {
            Chart(days) { day in
                let selected = day.id == selectedDay?.id
                BarMark(
                    x: .value("Day", day.dateInterval.start, unit: .day),
                    y: .value("Screen Time", day.totalActivity)
                )
                .foregroundStyle(selected ? .orange : .accentColor)
                .annotation(position: .top) {
                    Text(Duration.seconds(day.totalActivity).formatted(.time(pattern: .hourMinute)))
                        .font(.footnote)
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 7 * oneDay)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day))
            }
            .chartYAxis(.hidden)
            .chartScrollTargetBehavior(.valueAligned(matching: DateComponents(hour: 0), majorAlignment: .matching(DateComponents(day: 1))))
            .chartOverlay { chart in
                GeometryReader { geo in
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { point in
                            let date: Date? = chart.value(atX: point.x)
                            selectedDay = days.first { $0.dateInterval.contains(date ?? .now) }
                        }
                }
            }
            .padding()
            
            List {
                if let day = selectedDay {
                    ForEach(day.categories, id: \.self) { category in
                        Text(category.category.localizedDisplayName ?? "Name")
                            .badge(Duration.seconds(category.totalActivityDuration).formatted(.time(pattern: .hourMinute)))
                    }
                }
            }
        }
    }
}

struct Day: Identifiable {
    var id: Date { dateInterval.start }
    let totalActivity: Double
    let dateInterval: DateInterval
    let categories: [DeviceActivityData.CategoryActivity]
}

struct ScreenTimeReportScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .totalActivity
    let content: ([Day]) -> ScreenTimeReport
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> [Day] {
        await data.flatMap(\.activitySegments).map {
            await Day(totalActivity: $0.totalActivityDuration, dateInterval: $0.dateInterval, categories: $0.categories.collect())
        }.collect()
    }
}

extension AsyncSequence {
    func collect() async rethrows -> [Element] {
        try await reduce(into: [Element]()) { $0.append($1) }
    }
}
