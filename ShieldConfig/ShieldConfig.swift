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
    func getShield(name: String?) -> ShieldConfiguration {
        guard let name else { return .init() }
        return .init(
            backgroundBlurStyle: nil,
            backgroundColor: .systemBackground,
            icon: nil,
            title: .init(text: "Time's Up!", color: .label),
            subtitle: .init(text: "You blocked \(name.replacingOccurrences(of: "www.", with: ""))", color: .label),
            primaryButtonLabel: .init(text: "Close", color: .systemBackground),
            primaryButtonBackgroundColor: nil,
            secondaryButtonLabel: Date.now.isNight ? nil : .init(text: "1 more minute 😭", color: .red)
        )
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        getShield(name: application.localizedDisplayName)
    }

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        getShield(name: application.localizedDisplayName)
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        getShield(name: webDomain.domain)
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        getShield(name: webDomain.domain)
    }
}
