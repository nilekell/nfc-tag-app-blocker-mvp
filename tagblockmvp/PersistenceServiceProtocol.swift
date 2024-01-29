//
//  PersistenceServiceProtocol.swift
//  tagblockmvp
//
//  Created by Nile Kelly on 28/01/2024.
//

import Foundation

protocol PersistenceServiceProtocol {
    func save(isLocked: Bool)
    func loadIsLocked() -> Bool
}

class UserDefaultsPersistenceService: PersistenceServiceProtocol {
    func save(isLocked: Bool) {
        UserDefaults.standard.set(isLocked, forKey: "isLocked")
    }

    func loadIsLocked() -> Bool {
        UserDefaults.standard.bool(forKey: "isLocked")
    }
}

