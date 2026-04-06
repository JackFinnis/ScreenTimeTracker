//
//  ShieldActionExtension.swift
//  ScreenTimeShieldHandler
//
//  Created by Jack Finnis on 28/05/2024.
//

import Foundation
import ManagedSettings
import DeviceActivity
import FamilyControls
import UIKit

class ShieldHandler: ShieldActionDelegate {
    let bannedActivities: FamilyActivitySelection = FileStore.get(key: .bannedActivities) ?? .init()

    func handle(action: ShieldAction, banned: Bool, completion: @escaping (ShieldActionResponse) -> Void) {
        Task {
            switch action {
            case .secondaryButtonPressed:
                guard !banned else {
                    completion(.close)
                    return
                }
                try? await Task.sleep(for: .seconds(5))

                let schedule = DeviceActivitySchedule(
                    intervalStart: Date.now.addingTimeInterval(-oneHour).timeComponents,
                    intervalEnd: Date.now.addingTimeInterval(60).timeComponents,
                    repeats: false
                )
                do {
                    try DeviceActivityCenter().startMonitoring(.snooze, during: schedule)
                } catch {
                    print(error)
                }
                completion(.none)
            default:
                completion(.close)
            }
        }
    }

    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handle(action: action, banned: bannedActivities.applicationTokens.contains(application), completion: completionHandler)
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handle(action: action, banned: bannedActivities.categoryTokens.contains(category), completion: completionHandler)
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handle(action: action, banned: bannedActivities.webDomainTokens.contains(webDomain), completion: completionHandler)
    }
}
