//
//  MyShieldConfiguration.swift
//  tagblockmvp
//
//  Created by Nile Kelly on 29/01/2024.
//

import Foundation
import ManagedSettings
import ManagedSettingsUI
import SwiftUI

class MyShieldConfiguration: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Customize the shield as needed for applications.
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
}


class MyShieldActionExtension: ShieldActionDelegate {
    override func handle(action: ShieldAction,
                         for application: ApplicationToken, completionHandler:
                         @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(.close)
        // no action for secondary button as it is not shown
        case .secondaryButtonPressed:
            completionHandler(.none)
        @unknown default:
            fatalError()
        }
    }
}
