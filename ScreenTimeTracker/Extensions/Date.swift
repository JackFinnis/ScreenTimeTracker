//
//  Date.swift
//  ScreenTimeTracker
//
//  Created by Jack Finnis on 18/11/2024.
//

import Foundation

extension Date {
    subscript(_ component: Calendar.Component) -> Int {
        Calendar.current.component(component, from: self)
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var day: String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            return Calendar.current.weekdaySymbols[self[.weekday] - 1]
        }
    }
    
    var dayInitial: String {
        Calendar.current.shortWeekdaySymbols[self[.weekday] - 1]
    }
}
