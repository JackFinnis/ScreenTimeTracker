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
            ReportView(days: days)
        }
    }
}

struct ScreenTimeReportScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .totalActivity
    let content: ([Day]) -> ReportView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> [Day] {
        var days = [Day]()
        for await activity in data {
            for await segment in activity.activitySegments {
                days.append(Day(totalActivity: segment.totalActivityDuration, dateInterval: segment.dateInterval))
            }
        }
        return Array(days.drop { $0.totalActivity == 0 })
    }
}

struct Day: Identifiable, Equatable {
    var id: Date { dateInterval.start }
    let totalActivity: Double
    let dateInterval: DateInterval
}

struct ReportView: View {
    let days: [Day]
    
    var body: some View {
        ZStack {
            Chart(days) { day in
                let today = day == days.last
                BarMark(
                    x: .value("Total Activity", day.totalActivity),
                    y: .value("Date", day.dateInterval.start, unit: .day),
                    width: .ratio(0.9)
                )
                .cornerRadius(5)
                .foregroundStyle(today ? .indigo.opacity(0.5) : .indigo)
            }
            Chart(days.indices, id: \.self) { i in
                let day = days[i]
                let averageActivity = (-1...1).map { days[safe: i + $0] }.compactMap { $0 }.map(\.totalActivity).average()
                
                BarMark(
                    x: .value("Total Activity", day.totalActivity),
                    y: .value("Date", day.dateInterval.start, unit: .day)
                )
                .foregroundStyle(.clear)
                
                LineMark(
                    x: .value("Average Activity", averageActivity),
                    y: .value("Date", day.dateInterval.start, unit: .day)
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(.init(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .foregroundStyle(.orange)
            }
        }
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(preset: .aligned, values: .stride(by: 3600)) { value in
                if value.index > 0 {
                    AxisValueLabel(String(value.index))
                    AxisGridLine()
                }
            }
        }
        .chartXAxisLabel("Hours", alignment: .center)
        .padding(.trailing)
        .background(.background)
    }
}
