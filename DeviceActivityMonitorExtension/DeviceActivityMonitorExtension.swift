//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  Created by Nile Kelly on 29/01/2024.
//

import DeviceActivity
import ManagedSettings
import FamilyControls
import Foundation

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    let store = ManagedSettingsStore()
    
    let access: String = "Main app has access to DeviceActivityMonitorExtension"
    
    func setApplicationsToShield(applications: Set<ApplicationToken>) {
        print("DeviceActivityMonitor: setApplicationsToShield()")
        store.shield.applications = applications
        print("num blocked applications: \(store.shield.applications?.count ?? 0)")
    }
    
    func removeApplicationsFromShield() {
        print("DeviceActivityMonitor: removeApplicationsFromShield()")
        store.shield.applications = nil
        print("num blocked applications: \(store.shield.applications?.count ?? 0)")
    }
    
    // This will be triggered by the DeviceActivity framework when the interval starts
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("DeviceActivityMonitor: intervalDidStart")
        
        let selectionModel = SelectionModel()
        let applications = selectionModel.selectionToDiscourage
        print("\(store.shield.applications?.count ?? 0) applications set to be blocked")
        setApplicationsToShield(applications: applications.applicationTokens)
    }
    
    // This will be triggered by the DeviceActivity framework when the interval ends
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        print("DeviceActivityMonitor: intervalDidEnd")
        removeApplicationsFromShield()
    }
}
