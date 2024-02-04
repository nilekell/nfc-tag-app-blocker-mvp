//
//  ContentView.swift
//  tagblockmvp
//
//  Created by Nile Kelly on 28/01/2024.
//

import SwiftUI
import FamilyControls

struct ContentView: View {
    
    @EnvironmentObject var viewModel: DeviceActivityViewModel
    @State private var isChooseModeSheetPresented = false
    
    var body: some View {
        VStack {
            Text("Tenet")
                .padding()
            
            Button(action: scanButtonPressed, label: {
                Text("Scan tag")
            })
            .padding()
            
            Button("Choose mode") {
                isChooseModeSheetPresented = true
            }
            .padding()
            .disabled(viewModel.appModeModel.isLocked)
            
            Text("Restricted mode: \(viewModel.appModeModel.isLocked.description)")
                .padding()
        }
        .sheet(isPresented: $isChooseModeSheetPresented) {
            ChooseModeBottomSheetView(isPresented: $isChooseModeSheetPresented)
        }
        .onAppear {
            Task {
                await viewModel.setupMonitoring()
            }
        }
    }
    
    
    func scanButtonPressed() {
        viewModel.startNFCSensing()
    }
}



#Preview {
    ContentView()
}
