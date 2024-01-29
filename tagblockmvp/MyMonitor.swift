//
//  MyMonitor.swift
//  tagblockmvp
//
//  Created by Nile Kelly on 28/01/2024.
//

import DeviceActivity
import ManagedSettings
import FamilyControls

class MyMonitor: DeviceActivityMonitor {
    let store = ManagedSettingsStore()
    
    func setApplicationsToShield(applications: Set<ApplicationToken>) {
        store.shield.applications = applications
    }
    
    func removeApplicationsFromShield() {
        store.shield.applications = nil
    }
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        // This will be triggered by the DeviceActivity framework when the interval starts
        let selectionModel = SelectionModel()
        let applications = selectionModel.selectionToDiscourage
        setApplicationsToShield(applications: applications.applicationTokens)
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        // This will be triggered by the DeviceActivity framework when the interval ends
        removeApplicationsFromShield()
    }
}

