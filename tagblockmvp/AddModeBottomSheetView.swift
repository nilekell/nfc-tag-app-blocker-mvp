//
//  AddModeBottomSheetView.swift
//  tagblockmvp
//
//  Created by Nile Kelly on 04/02/2024.
//

import Foundation
import SwiftUI
import FamilyControls

struct AddModeBottomSheetView: View {
    @StateObject var chooseModeViewModel = ChooseModeViewModel.shared
    @Binding var isPresented: Bool
    @State private var newModeName = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {

            List {
                TextField("Mode name", text: $newModeName)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(16)
                
                Button("Submit") {
                    validate(name: newModeName)
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Invalid Mode Name"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func validate(name: String) {
        if name.count > 20 { // Assuming 20 is the max length you desire
            alertMessage = "The mode name is too long. Please use 20 characters or less."
            showingAlert = true
        } else if name.lowercased() == "default" {
            alertMessage = "The name 'default' is reserved. Please choose a different name."
            showingAlert = true
        } else {
            chooseModeViewModel.addSelectionMode(name: name)
            isPresented = false
        }
    }
    
}
