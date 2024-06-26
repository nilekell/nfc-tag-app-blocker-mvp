//
//  ChooseModeBottomSheet.swift
//  tagblockmvp
//
//  Created by Nile Kelly on 03/02/2024.
//

import Foundation
import SwiftUI
import FamilyControls

struct ChooseModeBottomSheetView: View {
    @EnvironmentObject var deviceActivityViewModel: DeviceActivityViewModel
    @StateObject var chooseModeViewModel = ChooseModeViewModel.shared
    @Binding var isPresented: Bool
    @State private var isAddModeSheetPresented = false
    @State var showingActivityPicker = false
    @State var editMode = EditMode.inactive
    
    
    var body: some View {
        // navigation stack required for edit mode to work
        NavigationStack {
            VStack {
                Text("Choose Mode")
                    .font(.headline)
                    .padding()
                
                // Displaying the list of SelectionModeEntities
                List {
                    ForEach(chooseModeViewModel.savedSelectionModeEntities, id: \.id) { selectionMode in
                        Button(action: {
                            selectionModeIsTapped(selectionMode: selectionMode)
                        }) {
                            HStack {
                                Text(selectionMode.name ?? "unknown")
                                Spacer()
                                Image(systemName: chooseModeViewModel.currentlySelectedMode?.id == selectionMode.id ? "checkmark.circle.fill" : "circle")
                            }
                        }
                        .deleteDisabled(selectionMode.name == "default")
                    }
                    .onDelete(perform: removeSelectionMode)
                    .environment(\.editMode, $editMode)
                }
                .toolbar {
                    EditButton()
                }
                .sheet(isPresented: $isAddModeSheetPresented) {
                    AddModeBottomSheetView(isPresented: $isAddModeSheetPresented)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .cornerRadius(10)
                
                Button("Add mode") {
                    isAddModeSheetPresented = true
                }
                
                // Button to show FamilyActivityPicker
                Button("Select apps to block for \(chooseModeViewModel.currentlySelectedMode!.name ?? "unknown")") {
                    showingActivityPicker = true
                }
                .padding()
                .disabled(deviceActivityViewModel.appModeModel.isLocked)
                .familyActivityPicker(isPresented: $showingActivityPicker,
                                      selection: $chooseModeViewModel.selection)
            }
        }
    }
    
    func removeSelectionMode(at offsets: IndexSet) {
        if let index = offsets.first {
            // Safely unwrap the id
            if let id = chooseModeViewModel.savedSelectionModeEntities[index].id {
                chooseModeViewModel.deleteSelectionModeByID(id)
            } else {
                print("Failed to find a valid ID for the selected item.")
                return
            }
        }
    }
        
    func selectionModeIsTapped(selectionMode: SelectionModeEntity) {
        chooseModeViewModel.updateCurrentlySelectedMode(selectionMode: selectionMode)
    }
}
