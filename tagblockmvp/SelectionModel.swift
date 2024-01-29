//
//  SelectionModel.swift
//  tagblockmvp
//
//  Created by Nile Kelly on 28/01/2024.
//

import Foundation
import FamilyControls

// represents currently discouraged apps
class SelectionModel {
    var selectionToDiscourage: FamilyActivitySelection
    
    init(selection: FamilyActivitySelection? = nil) {
        if let selection = selection {
            // Initialize with the given selection
            self.selectionToDiscourage = selection
        } else {
            // Initialize with a default selection from UserDefaults
            if let data = UserDefaults.standard.data(forKey: "discouragedApplications"),
               let savedSelection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
                // Initialize with saved selection
                self.selectionToDiscourage = savedSelection
            } else {
                // Initialize with a new selection if nothing is saved
                self.selectionToDiscourage = FamilyActivitySelection()
            }
        }
    }
    
    func saveSelectionToDiscourage() {
        if let data = try? JSONEncoder().encode(selectionToDiscourage) {
            UserDefaults.standard.set(data, forKey: "discouragedApplications")
        }
    }
}
