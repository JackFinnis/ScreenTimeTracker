//
//  ShieldConfigurationExtension.swift
//  ScreenTimeShield
//
//  Created by Jack Finnis on 28/05/2024.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfig: ShieldConfigurationDataSource {
    func getShield(id: String?, name: String?) -> ShieldConfiguration {
        return .init(
            backgroundBlurStyle: nil,
            backgroundColor: nil,
            icon: nil,
            title: .init(text: "", color: .label),
            subtitle: .init(text: "", color: .label),
            primaryButtonLabel: .init(text: name.map { "Close \($0)" } ?? "Close", color: .white),
            primaryButtonBackgroundColor: nil,
            secondaryButtonLabel: .init(text: "One More Minute", color: .tintColor)
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
