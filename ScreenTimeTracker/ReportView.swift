//
//  ReportView.swift
//  ScreenTimeTracker
//
//  Created by Jack Finnis on 14/05/2024.
//

import SwiftUI
import Charts

struct ReportView: View {
    let days: [Day]
    
    var body: some View {
        ZStack {
            Chart(days) { day in
                BarMark(
                    x: .value("Total Activity", day.totalActivity),
                    y: .value("Date", day.dateInterval.start, unit: .day),
                    width: .ratio(0.9)
                )
                .cornerRadius(5)
            }
            Chart(days.indices, id: \.self) { i in
                let day = days[i]
                let averageActivity = (-1...1).map { days[safe: i + $0] }.compactMap { $0 }.map(\.totalActivity).average()
                
                BarMark(
                    x: .value("Total Activity", day.totalActivity),
                    y: .value("Date", day.dateInterval.start, unit: .day)
                )
                .foregroundStyle(.clear)
                
                LineMark(
                    x: .value("Average Activity", averageActivity),
                    y: .value("Date", day.dateInterval.start, unit: .day)
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(.init(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .foregroundStyle(.orange)
            }
        }
        .chartYAxis(.hidden)
        .chartXAxis(.hidden)
        .chartYScale(domain: .automatic(reversed: true))
        .padding(.trailing)
        .ignoresSafeArea(edges: .bottom)
        .background(.background)
    }
}
