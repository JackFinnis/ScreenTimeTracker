//
//  ScreenTimeApp.swift
//  ScreenTime
//
//  Created by Jack Finnis on 05/03/2024.
//

import SwiftUI
import DeviceActivity
import FamilyControls
import StoreKit
import TelemetryDeck

@main
struct ScreenTimeApp: App {
    init() {
        let config = TelemetryDeck.Config(appID: "78E87044-7382-4F56-93EE-A878201B0C8E")
        TelemetryDeck.initialize(config: config)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// meh
// weekly total minutes
// "dont use chat software for longer than 30 minutes per week"
// disclosure sections for 3 types
// Screen time by hour of day not app
// Mon-Sun weekly average of unproductive and blocked apps
