//
//  main.swift
//  AIAssistantApp
//
//  Entry point for the AIAssistant GUI application
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import SwiftUI
import AIAssistantKit

@main
struct AIAssistantApp: App {
    @StateObject private var appController = AppController.shared
    
    var body: some Scene {
        WindowGroup {
            MasterView()
                .environmentObject(appController)
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About AIAssistant") {
                    appController.showAbout = true
                }
            }
        }
    }
}
