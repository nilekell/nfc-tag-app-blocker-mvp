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

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    let store = ManagedSettingsStore()
    let chooseModeViewModel = ChooseModeViewModel.shared

    let access: String = "Main app has access to DeviceActivityMonitorExtension"
    
    func setApplicationsToShield() {
        print("DeviceActivityMonitor: setApplicationsToShield()")
        
        var applications: Set<ApplicationToken> = Set()
        var categories: Set<ActivityCategoryToken> = Set()
        var webCategories: Set<WebDomainToken> = Set()

        if let selectionString = chooseModeViewModel.currentlySelectedMode?.selection {
            if let currentFamilyActivitySelection = FamilyActivitySelection.from(jsonString: selectionString) {
                applications = currentFamilyActivitySelection.applicationTokens
                categories = currentFamilyActivitySelection.categoryTokens
                webCategories = currentFamilyActivitySelection.webDomainTokens
            } else {
                print("Failed to unwrap: currentFamilyActivitySelection")
                return
            }
        } else {
            print("Failed to unwrap: selectionString")
            return
        }
        
        if applications.isEmpty {
            print("No applications to restrict")
        } else {
            store.shield.applications = applications
        }
        
        if categories.isEmpty {
            print("No categories to restrict")
        } else {
            store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(categories, except: Set()) // creating empty set, so there are no exceptions
        }
        
        if webCategories.isEmpty {
            print("No web categories to restrict")
        } else {
            store.shield.webDomains = webCategories
        }
        
        store.dateAndTime.requireAutomaticDateAndTime = true
        store.application.denyAppRemoval = true
        
        print("num blocked applications: \(applications.count)")
    }
    
    func removeApplicationsFromShield() {
        print("DeviceActivityMonitor: removeApplicationsFromShield()")
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomainCategories = nil
        store.shield.webDomains = nil
        
        store.dateAndTime.requireAutomaticDateAndTime = nil
        store.application.denyAppRemoval = nil
        
        print("num blocked applications: \(store.shield.applications?.count ?? 0)")
    }
    
    // This will be triggered by the DeviceActivity framework when the interval starts
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("DeviceActivityMonitor: intervalDidStart")
        setApplicationsToShield()
    }
    
    // This will be triggered by the DeviceActivity framework when the interval ends
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        print("DeviceActivityMonitor: intervalDidEnd")
        removeApplicationsFromShield()
    }
}
