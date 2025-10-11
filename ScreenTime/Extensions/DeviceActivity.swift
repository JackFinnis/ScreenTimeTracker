//
//  DeviceActivityReport.swift
//  ScreenTimeReport
//
//  Created by Jack Finnis on 05/03/2024.
//

import SwiftUI
@preconcurrency import DeviceActivity

extension DeviceActivityName {
    static let snooze = Self("snooze")
}

extension DeviceActivityReport.Context {
    static let activity = Self("activity")
}
