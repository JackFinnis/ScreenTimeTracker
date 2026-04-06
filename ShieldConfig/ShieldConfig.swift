//
//  ShieldConfigurationExtension.swift
//  ScreenTimeShield
//
//  Created by Jack Finnis on 28/05/2024.
//

import ManagedSettings
import ManagedSettingsUI
import FamilyControls
import SwiftUI

class ShieldConfig: ShieldConfigurationDataSource {
    let bannedActivities: FamilyActivitySelection = FileStore.get(key: .bannedActivities) ?? .init()

    func getShield(name: String?, banned: Bool) -> ShieldConfiguration {
        guard let name else { return .init() }
        let displayName = name.replacingOccurrences(of: "www.", with: "")
        if banned {
            return .init(
                backgroundBlurStyle: nil,
                backgroundColor: .systemBackground,
                icon: nil,
                title: .init(text: "Nope!", color: .label),
                subtitle: .init(text: "You blocked \(displayName)", color: .label),
                primaryButtonLabel: .init(text: "Close", color: .systemBackground),
                primaryButtonBackgroundColor: nil
            )
        } else {
            return .init(
                backgroundBlurStyle: nil,
                backgroundColor: .systemBackground,
                icon: nil,
                title: .init(text: "Time's Up!", color: .label),
                subtitle: .init(text: "You restricted \(displayName)", color: .label),
                primaryButtonLabel: .init(text: "Close", color: .systemBackground),
                primaryButtonBackgroundColor: nil,
                secondaryButtonLabel: .init(text: "1 more minute 😭", color: .red)
            )
        }
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        getShield(name: application.localizedDisplayName, banned: application.token.map { bannedActivities.applicationTokens.contains($0) } ?? false)
    }

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        getShield(name: application.localizedDisplayName, banned: application.token.map { bannedActivities.applicationTokens.contains($0) } ?? false)
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        getShield(name: webDomain.domain, banned: webDomain.token.map { bannedActivities.webDomainTokens.contains($0) } ?? false)
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        getShield(name: webDomain.domain, banned: webDomain.token.map { bannedActivities.webDomainTokens.contains($0) } ?? false)
    }
}
