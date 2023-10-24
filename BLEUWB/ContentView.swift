//
//  ContentView.swift
//  BLEUWB
//
//  Created by member on 2023/10/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var interactionManager : InteractionManager
    
    var body: some View {
        VStack {
            Text("Nearby Interaction")
                .font(.largeTitle)
            Text(interactionManager.DeviceU)
            // ... (other UI elements and interactions)
        }
        .onAppear {
            // ... (setup code, if needed)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(InteractionManager())
}
