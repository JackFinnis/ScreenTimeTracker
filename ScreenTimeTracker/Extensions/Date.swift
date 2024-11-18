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
    
    var day: String {
        Calendar.current.weekdaySymbols[self[.weekday] - 1]
    }
    
    var dayInitial: String {
        Calendar.current.veryShortWeekdaySymbols[self[.weekday] - 1]
    }
}
