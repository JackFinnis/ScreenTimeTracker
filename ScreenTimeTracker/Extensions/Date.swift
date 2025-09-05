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
    
    static var startOfToday: Date {
        Date.now.startOfDay
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var day: String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        } else if self > Calendar.current.date(byAdding: .day, value: -7, to: .startOfToday)! {
            return formatted(Date.FormatStyle().weekday(.wide))
        } else {
            return formatted(Date.FormatStyle().weekday(.wide).day().month())
        }
    }
    
    var dayInitial: String {
        if self > Calendar.current.date(byAdding: .day, value: -7, to: .startOfToday)! {
            return formatted(Date.FormatStyle().weekday())
        } else {
            return formatted(Date.FormatStyle().weekday().day())
        }
    }
}
