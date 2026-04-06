//
//  ActivityType.swift
//  ScreenTime
//
//  Created by Jack Finnis on 11/10/2025.
//

import SwiftUI

enum ActivityType: String, CaseIterable {
    case banned
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
            return .gray
        case .banned:
            return .red
        }
    }

    var name: String {
        switch self {
        case .banned:
            return "Blocked"
        case .blocked:
            return "Restricted"
        case .unproductive:
            return "Unproductive"
        case .productive:
            return "Productive"
        }
    }
}
