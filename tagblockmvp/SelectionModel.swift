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
    var selectionToDiscourage: FamilyActivitySelection {
        didSet {
            UserDefaultsPersistenceService.shared.saveSelection(selectionToDiscourage)
        }
    }
    
    init(selection: FamilyActivitySelection? = nil) {
        if let selection = selection {
            // Initialize with the given selection
            print("SelectionModel: init with given selection:")
            for application in selection.applications {
                print("\(application.localizedDisplayName ?? "unknown name")")
            }
            self.selectionToDiscourage = selection
            
        } else {
            self.selectionToDiscourage = UserDefaultsPersistenceService.shared.loadSelection() ?? FamilyActivitySelection()
        }
    }
}
