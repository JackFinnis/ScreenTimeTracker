//
//  Day.swift
//  ScreenTimeTracker
//
//  Created by Jack Finnis on 14/05/2024.
//

import Foundation

struct Day: Identifiable {
    var id: Date { dateInterval.start }
    let totalActivity: Double
    let dateInterval: DateInterval
}
