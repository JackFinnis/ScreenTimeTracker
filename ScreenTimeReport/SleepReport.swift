//
//  ScreenTimeReport.swift
//  ScreenTimeReport
//
//  Created by Jack Finnis on 05/03/2024.
//

import DeviceActivity
import SwiftUI
import Charts

struct SleepReportScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .sleep
    let content: ([Sleep]) -> SleepReportView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> [Sleep] {
        var hours = [Hour]()
        for await activity in data {
            for await segment in activity.activitySegments {
                let hour = Hour(dateInterval: segment.dateInterval, longestActivity: segment.longestActivity, firstPickup: segment.firstPickup, totalActivity: segment.totalActivityDuration)
                hours.append(hour)
            }
        }
        let dict = Dictionary(grouping: hours, by: \.dateInterval.start.startOfSleep)
        let sleeps = dict.compactMap { day, hours -> Sleep? in
            let waking = hours.filter(\.dateInterval.start.waking)
            let wake = waking.compactMap(\.firstPickup).first
            let sleeping = hours.filter(\.dateInterval.start.sleeping)
            let sleep = sleeping.compactMap { hour in
                hour.firstPickup?.addingTimeInterval(hour.totalActivity)
            }.last
            guard let wake, let sleep else { return nil }
            return Sleep(day: day, start: sleep, stop: wake)
        }
        return sleeps.sorted(using: SortDescriptor(\Sleep.day))
    }
}

struct Hour {
    let dateInterval: DateInterval
    let longestActivity: DateInterval?
    let firstPickup: Date?
    let totalActivity: Double
}

struct Sleep: Identifiable, Equatable {
    let day: Date
    let start: Date
    let stop: Date
    
    var id: Date { day }
    var startSeconds: TimeInterval { day.distance(to: start) }
    var stopSeconds: TimeInterval { day.distance(to: stop) }
    var duration: Duration { .seconds(start.distance(to: stop)) }
    var dayInterval: DateInterval { DateInterval(start: day, end: day.advanced(by: oneDay)) }
}

struct SleepReportView: View {
    @State var selectedDate: Date?
    @State var selectedSleep: Sleep?
    
    let sleeps: [Sleep]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Chart(sleeps) { sleep in
                    let selected = sleep == selectedSleep
                    RectangleMark(
                        xStart: .value("Start", sleep.startSeconds),
                        xEnd: .value("End", sleep.stopSeconds),
                        y: .value("Day", sleep.day, unit: .day),
                        height: .ratio(0.8)
                    )
                    .cornerRadius(5)
                    .foregroundStyle(selected ? .orange : .indigo)
                }
                .chartXScale(domain: .automatic(includesZero: false))
                .chartXAxis {
                    AxisMarks(preset: .aligned, position: .top, values: .stride(by: oneHour)) { value in
                        if let sleepSeconds = value.as(TimeInterval.self) {
                            AxisValueLabel(String(format: "%02d", (Int(sleepSeconds / oneHour) + 16) % 24))
                            AxisGridLine()
                        }
                    }
                }
                .chartYSelection(value: $selectedDate)
                .onChange(of: selectedDate) { _, date in
                    if let date {
                        selectedSleep = sleeps.first { $0.dayInterval.contains(date) }
                    }
                }
                .sensoryFeedback(.impact, trigger: selectedSleep)
                .chartYScale(range: .plotDimension(padding: 5))
                .chartYVisibleDomain(length: 30 * oneDay)
                .chartYAxis(.hidden)
                .defaultScrollAnchor(.bottom)
                
                HStack {
                    if let selectedSleep {
                        Text(selectedSleep.day.formatted(Date.FormatStyle().day().month()))
                            .font(.headline)
                        Spacer()
                        HStack(spacing: 20) {
                            VStack {
                                Text("Sleep")
                                    .font(.subheadline)
                                Text(selectedSleep.start.formatted(Date.FormatStyle().hour().minute()))
                            }
                            VStack {
                                Text("Wake")
                                    .font(.subheadline)
                                Text(selectedSleep.stop.formatted(Date.FormatStyle().hour().minute()))
                            }
                            VStack {
                                Text("Asleep")
                                    .font(.subheadline)
                                Text(selectedSleep.duration.formatted(Duration.TimeFormatStyle(pattern: .hourMinute(padHourToLength: 2))))
                            }
                        }
                    }
                }
                .monospacedDigit()
                .frame(height: 50)
            }
            .padding(.horizontal, 25)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Sleep Tracker")
                        .font(.title3.weight(.semibold))
                }
            }
        }
        .fontDesign(.rounded)
    }
}
