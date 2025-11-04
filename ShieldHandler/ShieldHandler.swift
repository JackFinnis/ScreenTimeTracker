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
    func handle(action: ShieldAction, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .secondaryButtonPressed:
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
            completionHandler(.none)
        default:
            completionHandler(.close)
        }
    }
    
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handle(action: action, completionHandler: completionHandler)
    }
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handle(action: action, completionHandler: completionHandler)
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handle(action: action, completionHandler: completionHandler)
    }
}
