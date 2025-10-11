//
//  UserDefaults.swift
//  ScreenTimeTracker
//
//  Created by Jack Finnis on 17/11/2024.
//

import Foundation

extension UserDefaults {
    static var shared: UserDefaults {
        UserDefaults(suiteName: "group.com.jackfinnis.ScreenTimeTracker")!
    }
}
