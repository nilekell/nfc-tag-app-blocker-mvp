//
//  DeviceActivityViewModel.swift
//  tagblockmvp
//
//  Created by Nile Kelly on 28/01/2024.
//

import DeviceActivity
import SwiftUI
import CoreNFC
import CoreData
import FamilyControls
import DeviceActivityMonitorExtension

class DeviceActivityViewModel: ObservableObject {
    
    @Published var appModeModel: AppModeModel {
        didSet {
            persistenceService.saveIsLocked(isLocked: appModeModel.isLocked)
        }
    }
    
    private let nfcReaderSessionManager = NFCReaderSessionManager()
    private let persistenceService = UserDefaultsPersistenceService.shared
    private let myMonitor = DeviceActivityMonitorExtension()
    
    private let ac = AuthorizationCenter.shared
    private let center = DeviceActivityCenter()
    private let schedule = DeviceActivitySchedule(
        intervalStart: DateComponents(hour: 0, minute: 0),
        intervalEnd: DateComponents(hour: 23, minute: 59),
        repeats: true
    )
    
    private var nfcSession: NFCNDEFReaderSession?
    
    init() {
        // getting data to determine whether app is in locked mode or not
        let isLocked = persistenceService.loadIsLocked()
        self.appModeModel = AppModeModel(isLocked: isLocked)
        
        // Configure NFC Reader Manager
        configureNFCReaderSessionManager()
    }
    
    // NFC Session Management Logic
    
    private func configureNFCReaderSessionManager() {
        nfcReaderSessionManager.onNFCResult = { [weak self] in
            self?.toggleApplicationMode()
        }
    }
    
    // Use this method to start NFC sensing
    func startNFCSensing() {
        nfcReaderSessionManager.startNFCSensing()
    }
    
    // Application Monitoring logic
    
    func setupMonitoring() async {
        do {
            try await ac.requestAuthorization(for: .individual)
            try center.startMonitoring(.daily, during: schedule)
        } catch {
            print("Failed to start monitoring: \(error)")
        }
    }
    
    func toggleApplicationMode() {
        DispatchQueue.main.async {
            self.appModeModel.isLocked.toggle()
            if self.appModeModel.isLocked {
                self.startMonitoring()
            } else {
                // Remove restrictions
                self.endMonitoring()
            }
        }
    }
    
    private func startMonitoring() {
        // Here you can start monitoring and set the initial shielding based on the model
        myMonitor.setApplicationsToShield()
        appModeModel.isLocked = true
    }
    
    private func endMonitoring() {
        // Remove all application shields when monitoring ends
        myMonitor.removeApplicationsFromShield()
        appModeModel.isLocked = false
    }
}
