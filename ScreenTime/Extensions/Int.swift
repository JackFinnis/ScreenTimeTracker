//
//  Int.swift
//  ScreenTimeTracker
//
//  Created by Jack Finnis on 17/11/2024.
//

import Foundation

extension Int {
    func formatted(singular: String) -> String {
        "\(self == 0 ? "No" : String(self)) \(singular)\(self == 1 ? "" : "s")"
    }
}
