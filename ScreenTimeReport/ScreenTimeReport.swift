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
