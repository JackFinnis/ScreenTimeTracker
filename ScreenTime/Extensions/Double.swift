//
//  Double.swift
//  ScreenTime
//
//  Created by Jack Finnis on 11/10/2025.
//

import Foundation

extension Double {
    var formattedDuration: String {
        Duration.seconds(self).formatted(Duration.UnitsFormatStyle(allowedUnits: [.hours, .minutes], width: .narrow))
    }
}
