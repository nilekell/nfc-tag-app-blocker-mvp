//
//  DataController.swift
//  tagblockmvp
//
//  Created by Nile Kelly on 03/02/2024.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "tagblockmvp")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
