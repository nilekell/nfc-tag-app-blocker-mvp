//
//  MyMonitor.swift
//  tagblockmvp
//
//  Created by Nile Kelly on 28/01/2024.
//

import DeviceActivity
import ManagedSettings
import FamilyControls
import Foundation

class MyMonitor: DeviceActivityMonitor {
    let store = ManagedSettingsStore()
    let ac = AuthorizationCenter.shared
    
    private let center = DeviceActivityCenter()
    private let schedule = DeviceActivitySchedule(
        intervalStart: DateComponents(hour: 0, minute: 0),
        intervalEnd: DateComponents(hour: 23, minute: 59),
        repeats: true
    )
    
    override init() {
        super.init()
        
        Task {
            do {
                try await ac.requestAuthorization(for: .individual)
            }
            catch {
                print("Failed to get Screen Time Authorization.")
            }
        }
    }
    
    func setApplicationsToShield(applications: Set<ApplicationToken>) {
        print("DeviceActivityMonitor: blocked applications")
        
        do {
            store.shield.applications = applications
            try center.startMonitoring(.daily, during: schedule)
        } catch {
            print("Error starting device activity monitoring: \(error)")
        }
        
        print("num blocked applications: \(store.shield.applications?.count ?? 0)")
    }
    
    func removeApplicationsFromShield() {
        print("DeviceActivityMonitor: unblocked applications")
        
        store.shield.applications = nil
        center.stopMonitoring([DeviceActivityName.daily])
        
        print("num blocked applications: \(store.shield.applications?.count ?? 0)")
    }
    
    // This will be triggered by the DeviceActivity framework when the interval starts
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        print("DeviceActivityMonitor: intervalDidStart")
        let selectionModel = SelectionModel()
        let applications = selectionModel.selectionToDiscourage
        print(store.application.blockedApplications!)
        setApplicationsToShield(applications: applications.applicationTokens)
    }
    
    // This will be triggered by the DeviceActivity framework when the interval ends
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        print("DeviceActivityMonitor: intervalDidEnd")
        removeApplicationsFromShield()
    }
}

