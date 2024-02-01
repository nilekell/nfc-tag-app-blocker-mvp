//
//  PersistenceServiceProtocol.swift
//  tagblockmvp
//
//  Created by Nile Kelly on 28/01/2024.
//

import Foundation
import FamilyControls

protocol PersistenceServiceProtocol {
    func saveIsLocked(isLocked: Bool)
    func loadIsLocked() -> Bool
    func saveSelection(_ selection: FamilyActivitySelection)
    func loadSelection() -> FamilyActivitySelection?
}

class UserDefaultsPersistenceService: PersistenceServiceProtocol {
    
    static let shared = UserDefaultsPersistenceService()
    private let storage: UserDefaults

    private init() {
        storage = UserDefaults(suiteName: "private_shared_storage")!
    }
    
    func saveIsLocked(isLocked: Bool) {
        storage.set(isLocked, forKey: "isLocked")
    }
    
    func loadIsLocked() -> Bool {
        storage.bool(forKey: "isLocked")
    }
    
    func saveSelection(_ selection: FamilyActivitySelection) {
        if let data = try? JSONEncoder().encode(selection) {
            storage.set(data, forKey: "discouragedApplications")
            
            print("updated new selection:")
            for application in selection.applications {
                print("\(application.localizedDisplayName?.description ?? "unknown name")")
            }
        }
    }
    
    func loadSelection() -> FamilyActivitySelection? {
        guard let data = storage.data(forKey: "discouragedApplications") else {
            print("failed to get selection")
            return nil
        }
        return try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
    }
}

