//
//  ShieldConfigurationExtension.swift
//  ScreenTimeShield
//
//  Created by Jack Finnis on 28/05/2024.
//

import ManagedSettings
import ManagedSettingsUI
import SwiftUI

class ShieldConfig: ShieldConfigurationDataSource {
    func getShield(id: String?, name: String?) -> ShieldConfiguration {
        return .init(
            backgroundBlurStyle: nil,
            backgroundColor: nil,
            icon: nil,
            title: .init(text: "Time's up!", color: .label),
            subtitle: .init(text: name.map { "You blocked \($0)" } ?? "", color: .label),
            primaryButtonLabel: .init(text: "One More Minute 😭", color: .white),
            primaryButtonBackgroundColor: .red,
            secondaryButtonLabel: .init(text: "Close 🥳", color: .label)
        )
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        getShield(id: application.bundleIdentifier, name: application.localizedDisplayName)
    }
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        getShield(id: application.bundleIdentifier, name: application.localizedDisplayName)
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        getShield(id: webDomain.domain, name: webDomain.domain)
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        getShield(id: webDomain.domain, name: webDomain.domain)
    }
}
