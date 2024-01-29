//
//  NFCReader.swift
//  tagblockmvp
//
//  Created by Nile Kelly on 28/01/2024.
//

import Foundation
import CoreNFC
import SwiftUI

class NFCReader: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    
    var data: Data?
    var nfcSession: NFCNDEFReaderSession?
    var str: String = ""
    
    var viewModel: DeviceActivityViewModel?
    
    init(viewModel: DeviceActivityViewModel) {
        self.viewModel = viewModel
    }
    
    func scan() {
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Hold Your iPhone Near an NFC Card"
        nfcSession?.begin()
    }
    
    func invalidateSessionWithMessage(session: NFCNDEFReaderSession, message: String) {
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
        DispatchQueue.main.async {
            // Process first detected NFCNDEFMessage objects.
            let firstNDEFMessage = messages[0]
            self.data = firstNDEFMessage.records.first?.payload ?? Data()
            self.str = String(decoding: self.data ?? Data(), as: UTF8.self)
            
            // call updates here
            self.nfcSession = nil
        }
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
                    self.invalidateSessionWithMessage(session: session, message: "Unable to connect to tag.")
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
                            self.invalidateSessionWithMessage(session: session, message: "Unable to read data on tag.")
                            return
                        }
                        
                        guard ndefMessage == nil else {
                            self.invalidateSessionWithMessage(session: session, message: "Unable to read data on tag.")
                            return
                        }
                        
                        guard !(ndefMessage?.records.isEmpty)!, ndefMessage!.records[0].typeNameFormat != .empty else {
                            self.invalidateSessionWithMessage(session: session, message: "Unable to read data on tag.")
                            return
                        }
                        
                        // call updates here for initial testing
                        self.nfcSession = nil
                    })
                    
                @unknown default:
                    self.invalidateSessionWithMessage(session: session, message: "Unable to read data on tag.")
                }
            })
        })
    }
}
