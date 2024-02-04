//
//  PersistenceServiceProtocol.swift
//  tagblockmvp
//
//  Created by Nile Kelly on 28/01/2024.
//

import Foundation
import FamilyControls

class UserDefaultsPersistenceService {
    
    static let shared = UserDefaultsPersistenceService()
    private let storage: UserDefaults
    private let suiteName = "private_shared_storage"

    private init() {
        storage = UserDefaults(suiteName: suiteName)!
        self.saveCurrentSelectionMode(selectionModeKey: "default")
    }
    
    func saveIsLocked(isLocked: Bool) {
        storage.set(isLocked, forKey: "isLocked")
    }
    
    func loadIsLocked() -> Bool {
        storage.bool(forKey: "isLocked")
    }
    
    func saveCurrentSelectionMode(selectionModeKey: String) {
        storage.set(selectionModeKey, forKey: "currentSelectionMode")
    }
    
    func loadCurrentSelectionMode() -> String {
        storage.string(forKey: "currentSelectionMode")!
    }
}

