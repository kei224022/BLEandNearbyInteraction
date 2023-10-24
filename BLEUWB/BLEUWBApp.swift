//
//  BLEUWBApp.swift
//  BLEUWB
//
//  Created by member on 2023/10/24.
//

import SwiftUI

@main
struct BLEUWBApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(InteractionManager())
        }
    }
}
