//
//  Date.swift
//  ScreenTimeTracker
//
//  Created by Jack Finnis on 18/11/2024.
//

import Foundation

let oneHour: Double = 3600
let oneDay = oneHour * 24

extension Date {
    subscript(_ component: Calendar.Component) -> Int {
        Calendar.current.component(component, from: self)
    }
    
    var timeComponents: DateComponents {
        Calendar.current.dateComponents([.hour, .minute, .second], from: self)
    }
    
    static var startOfToday: Date {
        Date.now.startOfDay
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var isNight: Bool {
        self[.hour] >= 9 || self[.hour] < 9
    }
}
