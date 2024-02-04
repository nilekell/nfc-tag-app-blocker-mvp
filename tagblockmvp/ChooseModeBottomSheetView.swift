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
        NavigationStack {
            VStack {
                Text("Choose Mode")
                    .font(.headline)
                    .padding()
                
                // Displaying the list of SelectionModeEntities
                List {
                    ForEach(chooseModeViewModel.savedSelectionModeEntities, id: \.id) { selectionMode in
                        Text(selectionMode.name ?? "Unknown")
                            .deleteDisabled(selectionMode.name == "default")
                    }
                    .onDelete(perform: removeSelectionMode)
                    .environment(\.editMode, $editMode)
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
        .toolbar {
            EditButton()
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
}
