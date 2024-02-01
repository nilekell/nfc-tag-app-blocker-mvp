//
//  ShieldConfigurationExtension.swift
//  ShieldConfigurationExtension
//
//  Created by Nile Kelly on 29/01/2024.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    private func commonShieldConfiguration() -> ShieldConfiguration {
            return ShieldConfiguration(
                backgroundBlurStyle: UIBlurEffect.Style.systemMaterialLight,
                backgroundColor: UIColor(red: 0.71, green: 0.66, blue: 0.98, alpha: 1.00),
                // icon: UIImage(named: "icon-name"),
                title: ShieldConfiguration.Label(text: "Life is short.", color: .black),
                subtitle: ShieldConfiguration.Label(text: "Resist temptation", color: .black),
                primaryButtonLabel: ShieldConfiguration.Label(text: "Thanks!", color: .white),
                primaryButtonBackgroundColor: UIColor.black
                // secondaryButtonLabel: ShieldConfiguration.Label(text: "Break 👀", color: .black)
            )
        }
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Customize the shield as needed for applications.
        commonShieldConfiguration()
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for applications shielded because of their category.
        commonShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Customize the shield as needed for web domains.
        commonShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for web domains shielded because of their category.
        commonShieldConfiguration()
    }
}
