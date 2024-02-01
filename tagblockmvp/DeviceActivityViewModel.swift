//
//  DeviceActivityViewModel.swift
//  tagblockmvp
//
//  Created by Nile Kelly on 28/01/2024.
//

import DeviceActivity
import SwiftUI
import CoreNFC
import FamilyControls
import DeviceActivityMonitorExtension

class DeviceActivityViewModel: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    // singleton instance
    static let shared = DeviceActivityViewModel()
    
    @Published var appModeModel: AppModeModel {
        didSet {
            persistenceService.saveIsLocked(isLocked: appModeModel.isLocked)
        }
    }
    
    // Managing selected apps to block logic
    
    @Published var selectionModel = SelectionModel.shared
    
    var selectionToDiscourage: FamilyActivitySelection {
        // retrieves current value of selectionToDiscourage from SelectionModel
        get { selectionModel.selectionToDiscourage }
        set { selectionModel.selectionToDiscourage = newValue }
    }
    
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
    
    override init() {
        // getting data to determine whether app is in locked mode or not
        let isLocked = persistenceService.loadIsLocked()
        self.appModeModel = AppModeModel(isLocked: isLocked)
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
    
    // NFC Delegate logic
    
    func startNFCSensing() {
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Hold your iPhone near an NFC tag"
        nfcSession?.begin()
    }
    
    private func invalidateSessionWithMessage(session: NFCNDEFReaderSession, message: String) {
        session.alertMessage = message
        session.invalidate()
    }
    
    // called when the reader-session expired, you invalidated the dialog or accessed an invalidated session
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("Error reading NFC: \(error.localizedDescription)")
    }
    
    // called when a reader session begins
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("Reader session activated.")
    }

    // called when a new set of NDEF messages is found
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("New NDEF messages found.")
    }
    
    // called when a a tag is detected
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than one Tag Detected, please try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }
        
        let tag = tags.first!
        session.connect(to: tag, completionHandler: {(error: Error?) in
            if nil != error {
                self.invalidateSessionWithMessage(session: session, message: "Unable to connect to tag.")
                return
            }
            
            tag.queryNDEFStatus(completionHandler: {(ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                guard error == nil else {
                    self.invalidateSessionWithMessage(session: session, message: "Unable to query NDEF status.")
                    return
                }
                
                switch ndefStatus {
                case .notSupported:
                    self.invalidateSessionWithMessage(session: session, message: "Unable to connect to tag. This tag is not supported.")
                case .readOnly:
                    self.invalidateSessionWithMessage(session: session, message: "Unable to connect to tag. This tag is read only.")
                case .readWrite:
                    tag.readNDEF(completionHandler: {(ndefMessage: NFCNDEFMessage?, error: Error?) in
                        guard error == nil else {
                            print("NFC Read Error: \(error!.localizedDescription)")
                            self.invalidateSessionWithMessage(session: session, message: "Unable to read data on tag.")
                            return
                        }
                        
                        guard let ndefMessage = ndefMessage else {
                            print("NFC Read Error: ndefMessage is nil")
                            self.invalidateSessionWithMessage(session: session, message: "Unable to read data on tag.")
                            return
                        }
                        
                        DispatchQueue.main.async {
                            // Process NFC messages
                            if let firstRecord = ndefMessage.records.first {
                                print(firstRecord.typeNameFormat)
                                print(firstRecord.payload)
                                print(firstRecord.wellKnownTypeTextPayload())
                            } else {
                                print("No records in the ndefMessage")
                            }
                            
                            // Invalidate the session when done
                            session.invalidate()
                            
                            self.nfcSession = nil
                            self.toggleApplicationMode()
                        }
                    })
                    
                @unknown default:
                    print("NFC Read Error: Unknown NFC tag status")
                    self.invalidateSessionWithMessage(session: session, message: "Unable to read data on tag.")
                }
            })
        })
    }
}
