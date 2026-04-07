//
//  DeviceActivityMonitorExtension.swift
//  ScreenTimeMonitor
//
//  Created by Jack Finnis on 28/05/2024.
//

import DeviceActivity
@preconcurrency import ManagedSettings
import FamilyControls
import Foundation

extension ManagedSettingsStore.Name {
    static let blocked = Self("blocked")
    static let banned = Self("banned")
}

class ActivityMonitor: DeviceActivityMonitor {
    let blockedSettings = ManagedSettingsStore(named: .blocked)
    let bannedSettings = ManagedSettingsStore(named: .banned)
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
        blockedSettings.shield.applications = nil
        blockedSettings.shield.webDomains = nil
    }

    func blockActivities() {
        guard let blockedActivities: FamilyActivitySelection = FileStore.get(key: .blockedActivities) else { return }
        blockedSettings.shield.applications = blockedActivities.applicationTokens
        blockedSettings.shield.webDomains = blockedActivities.webDomainTokens
    }

    func banActivities() {
        guard let bannedActivities: FamilyActivitySelection = FileStore.get(key: .bannedActivities) else { return }
        bannedSettings.shield.applications = bannedActivities.applicationTokens
        bannedSettings.shield.webDomains = bannedActivities.webDomainTokens
    }

    func reset() {
        ManagedSettingsStore().clearAllSettings()
        blockActivities()
        banActivities()
        activityCenter.stopMonitoring()
    }
}
