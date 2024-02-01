//
//  ContentView.swift
//  tagblockmvp
//
//  Created by Nile Kelly on 28/01/2024.
//

import SwiftUI
import FamilyControls

struct ContentView: View {
    
    @StateObject var viewModel = DeviceActivityViewModel.shared
    @State var isPresented = false
    
    var body: some View {
        VStack {
            Text("App Blocker")
                .padding()
            
            Button("Select apps to block") { isPresented = true }
                .padding()
                .disabled(viewModel.appModeModel.isLocked)
                .familyActivityPicker(isPresented: $isPresented,
                                      selection: $viewModel.selectionToDiscourage)
            
            Button(action: scanButtonPressed, label: {
                Text("Scan tag")
            })
            .padding()
            
            Text("Restricted mode: \(viewModel.appModeModel.isLocked.description)")
                .padding()
        }
        .onChange(of: viewModel.selectionModel.selectionToDiscourage) { newSelection in
            viewModel.updateSelection(newSelection)
        }
    }
    
    
    func scanButtonPressed() {
        viewModel.startNFCSensing()
    }
}



#Preview {
    ContentView()
}
