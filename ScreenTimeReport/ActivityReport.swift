//
//  ScreenTimeReport.swift
//  ScreenTimeReport
//
//  Created by Jack Finnis on 05/03/2024.
//

import DeviceActivity
import SwiftUI
import Charts

struct Day: Identifiable, Equatable {
    var id: Date { dateInterval.start }
    let totalActivity: Double
    let dateInterval: DateInterval
}

struct ActivityReportScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .activity
    let content: ([Day]) -> ActivityReportView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> [Day] {
        var days: [Day] = []
        for await activity in data {
            for await segment in activity.activitySegments  {
                var totalActivity: Double = 0
                for await category in segment.categories {
                    for await application in category.applications {
                        guard let bundleIdentifier = application.application.bundleIdentifier,
                              bundleIdentifier != "net.whatsapp.WhatsApp",
                              !bundleIdentifier.starts(with: "com.jackfinnis")
                        else { continue }
                        totalActivity += application.totalActivityDuration
                    }
                }
                if totalActivity != 0 {
                    days.append(Day(totalActivity: totalActivity, dateInterval: segment.dateInterval))
                }
            }
        }
        return days
    }
}

struct ActivityReportView: View {
    let days: [Day]
    
    var body: some View {
        Chart(days) { day in
            let today = day == days.last
            BarMark(
                x: .value("Total Activity", day.totalActivity),
                y: .value("Date", day.dateInterval.start, unit: .day)
            )
            .foregroundStyle(.indigo.opacity(today ? 0.5 : 1))
        }
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(preset: .aligned, values: .stride(by: 3600)) { value in
                if value.index > 0 && value.index != value.count - 1 {
                    AxisValueLabel(String(value.index))
                    AxisGridLine()
                }
            }
        }
        .chartXAxisLabel("Wasted Hours", alignment: .center)
        .padding(.top)
        .background(.background)
    }
}
