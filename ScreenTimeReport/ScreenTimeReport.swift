//
//  ScreenTimeReportExtension.swift
//  ScreenTimeTracker
//
//  Created by Jack Finnis on 05/10/2024.
//

import DeviceActivity
import SwiftUI

@main
struct ScreenTimeReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        ActivityReportScene { days in
            ActivityReportView(days: days)
        }
        SleepReportScene { days in
            SleepReportView(days: days)
        }
    }
}
