//
//  ChooseModeViewModel.swift
//  tagblockmvp
//
//  Created by Nile Kelly on 03/02/2024.
//

import Foundation
import CoreData
import FamilyControls

class ChooseModeViewModel: ObservableObject {
    
    static let shared = ChooseModeViewModel()
    
    @Published var currentlySelectedMode: SelectionModeEntity?
    @Published var savedSelectionModeEntities: [SelectionModeEntity] = []
    @Published var selection = FamilyActivitySelection()
    
    var container: NSPersistentContainer?
    private let persistenceService = UserDefaultsPersistenceService.shared
    
    init() {
        container = NSPersistentContainer(name: "tagblockmvp")
        container!.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            } else {
                print("Core Data loaded successfully")
            }
        }
        
        // Create 'default' SelectionModeEntity if it doesn't exist
        createDefaultSelectionModeIfNeeded()
        // Get currently selected mode from user defaults
        currentlySelectedMode = fetchCurrentlySelectedMode()
        // Get FamilyActivitySelection for currently selected mode
        selection = getFamilyActivitySelectionFromSelectionModeEntity()
        fetchSelectionModes()
    }
    
    private func createDefaultSelectionModeIfNeeded() {
        // setting up request to core data to fetch SelectionMode named "default"
        let request: NSFetchRequest<SelectionModeEntity> = SelectionModeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", "default")

        do {
            let results = try container!.viewContext.fetch(request)
            if results.isEmpty {
                let newDefaultMode = SelectionModeEntity(context: container!.viewContext)
                newDefaultMode.name = "default"
                newDefaultMode.id = UUID()
                newDefaultMode.selection = FamilyActivitySelection().jsonString()
                try container!.viewContext.save()
            }
        } catch {
            print("Error creating default mode: \(error)")
        }
    }
    
    func fetchCurrentlySelectedMode() -> SelectionModeEntity {
        let currentlySelectedModeUuidString = persistenceService.loadCurrentSelectionMode()

        guard let uuid = UUID(uuidString: currentlySelectedModeUuidString) else {
            return fetchDefaultSelectionMode()
        }

        let request: NSFetchRequest<SelectionModeEntity> = SelectionModeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", "id", uuid as CVarArg)

        do {
            let selectedModes = try container!.viewContext.fetch(request)
            return selectedModes.first ?? fetchDefaultSelectionMode()
        } catch {
            print("Error fetching the currently selected mode: \(error)")
            return fetchDefaultSelectionMode()
        }
    }
    
    private func getFamilyActivitySelectionFromSelectionModeEntity() -> FamilyActivitySelection {
        guard let selectionString = currentlySelectedMode?.selection else {
            print("No selection string available in currently selected mode")
            return FamilyActivitySelection()
        }

        guard let data = selectionString.data(using: .utf8) else {
            print("Unable to convert selection string to Data")
            return FamilyActivitySelection()
        }

        let decoder = JSONDecoder()
        do {
            let selection = try decoder.decode(FamilyActivitySelection.self, from: data)
            return selection
        } catch {
            print("Error decoding selection: \(error)")
            return FamilyActivitySelection()
        }
    }

    private func fetchDefaultSelectionMode() -> SelectionModeEntity {
        let request: NSFetchRequest<SelectionModeEntity> = SelectionModeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", "default")

        do {
            let results = try container!.viewContext.fetch(request)
            return results.first! // Assuming there will always be a 'default' mode
        } catch {
            fatalError("Default SelectionModeEntity could not be fetched: \(error)")
        }
    }
    
    func fetchSelectionModes() {
        let request = NSFetchRequest<SelectionModeEntity>(entityName: "SelectionModeEntity")
        do {
           savedSelectionModeEntities = try container!.viewContext.fetch(request)
        } catch let error {
            print("Error fetching: .\(error)")
        }
    }
    
    func saveData() {
        do {
            try container!.viewContext.save()
            fetchSelectionModes()
        } catch let error {
            print("Error fetching: .\(error)")
        }
    }
    
    func addSelectionMode(name: String) {
        let newSelectionMode = SelectionModeEntity(context: container!.viewContext)
        newSelectionMode.id = UUID()
        newSelectionMode.name = name
        newSelectionMode.selection = FamilyActivitySelection().jsonString()
        saveData()
    }
    
    func deleteSelectionModeByID(_ id: UUID) {
        let context = container!.viewContext
        let fetchRequest: NSFetchRequest<SelectionModeEntity> = SelectionModeEntity.fetchRequest()

        // Set the predicate to match the entity with the given ID
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)

            // Assuming 'id' is unique, there should be at most one result
            if let entityToDelete = results.first {
                context.delete(entityToDelete)

                saveData()
            } else {
                print("No entity found with the given ID.")
            }
        } catch {
            print("Error fetching or deleting entity:", error.localizedDescription)
        }
    }
}
