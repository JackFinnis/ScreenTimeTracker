//
//  ScreenTimeReport.swift
//  ScreenTimeReport
//
//  Created by Jack Finnis on 05/03/2024.
//

import DeviceActivity
import SwiftUI

@main
struct ScreenTimeReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        ScreenTimeReportScene { days in
            ScreenTimeReport(days: days)
        }
    }
}

struct ScreenTimeReportScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .totalActivity
    let content: ([Day]) -> ScreenTimeReport
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> [Day] {
        var days = [Day]()
        for await activity in data {
            for await segment in activity.activitySegments {
                days.append(Day(totalActivity: segment.totalActivityDuration, dateInterval: segment.dateInterval))
            }
        }
        return days
    }
}

struct ScreenTimeReport: View {
    let days: [Day]
    
    var body: some View {
        let max = days.map(\.totalActivity).max()!
        
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(days.reversed()) { day in
                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(width: geo.size.width * day.totalActivity/max, height: 25)
                            .clipShape(UnevenRoundedRectangle(bottomTrailingRadius: 5, topTrailingRadius: 5))
                            .contextMenu {
                                Section(day.dateInterval.start.formatted(date: .abbreviated, time: .omitted)) {
                                    Text(Duration.seconds(day.totalActivity).formatted(.time(pattern: .hourMinute)))
                                }
                            }
                    }
                }
                .background(.background)
            }
            .scrollIndicators(.hidden)
        }
    }
}

struct Day: Identifiable {
    var id: Date { dateInterval.start }
    let totalActivity: Double
    let dateInterval: DateInterval
}
