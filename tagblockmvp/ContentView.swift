//
//  ContentView.swift
//  tagblockmvp
//
//  Created by Nile Kelly on 28/01/2024.
//

import SwiftUI
import FamilyControls

struct ContentView: View {
    
    @State var isLockedMode = false
    @State var selectionToDiscourage = FamilyActivitySelection()
    @State var isPresented = false
    @State var reader = NFCReader()
    
    var body: some View {
        VStack {
            Text("App Blocker")
                .padding()
            Button("Select apps to block") { isPresented = true }
                   .familyActivityPicker(isPresented: $isPresented,
                                         selection: $selectionToDiscourage)
                   .padding()
            Button(action: {
                reader.scan()
            }, label: {
                Text("Scan tag")
            })
            
            // Displaying the scanned data
            Text(reader.str)
                .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
