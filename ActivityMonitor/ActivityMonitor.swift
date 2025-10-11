//
//  DeviceActivityMonitorExtension.swift
//  ScreenTimeMonitor
//
//  Created by Jack Finnis on 28/05/2024.
//

import DeviceActivity
import ManagedSettings
import FamilyControls
import Foundation

class ActivityMonitor: DeviceActivityMonitor {
    let settings = ManagedSettingsStore()
    let activityCenter = DeviceActivityCenter()
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        unblockActivities()
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        blockActivities()
    }
    
    func unblockActivities() {
        settings.shield.applications = nil
        settings.shield.webDomains = nil
    }
    
    func blockActivities() {
        guard let blockedActivities: FamilyActivitySelection = FileStore.get(key: .blockedActivities) else { return }
        settings.shield.applications = blockedActivities.applicationTokens
        settings.shield.webDomains = blockedActivities.webDomainTokens
    }
    
    func reset() {
        blockActivities()
        activityCenter.stopMonitoring()
    }
}
