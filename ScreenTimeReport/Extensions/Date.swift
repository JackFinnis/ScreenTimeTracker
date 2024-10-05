//
//  Date.swift
//  SleepTime
//
//  Created by Jack Finnis on 06/02/2024.
//

import Foundation

let sleepDayHour = 16
let oneHour = TimeInterval(60 * 60)
let oneDay = oneHour * 24

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    var endOfDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
    }
    
    var startOfSleep: Date {
        let sleepDay = self[.hour] < sleepDayHour ? startOfDay : endOfDay
        return Calendar.current.date(byAdding: .hour, value: sleepDayHour - 24, to: sleepDay)!
    }
    
    var sleeping: Bool {
        let hour = self[.hour]
        return hour >= sleepDayHour || hour < 5
    }
    var waking: Bool {
        !sleeping
    }
    
    subscript(component: Calendar.Component) -> Int {
        Calendar.current.component(component, from: self)
    }
}
