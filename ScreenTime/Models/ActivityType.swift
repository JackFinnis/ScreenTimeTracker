//
//  ActivityType.swift
//  ScreenTime
//
//  Created by Jack Finnis on 11/10/2025.
//

import SwiftUI

enum ActivityType: String, CaseIterable {
    case blocked
    case unproductive
    case productive

    var color: Color {
        switch self {
        case .productive:
            return .green
        case .unproductive:
            return .yellow
        case .blocked:
            return .red
        }
    }

    var name: String {
        rawValue.capitalized
    }
}
