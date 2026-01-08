//
//  SettingsTabView.swift
//  AIAssistantApp
//
//  Settings interface tab view
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import SwiftUI
import AIAssistantKit

/// Settings tab view for application configuration.
struct SettingsTabView: View {
    @EnvironmentObject var controller: AppController
    @State private var apiKey: String = ""
    @State private var modelSelection: String = "GPT-4"
    @State private var enableVoice: Bool = true
    @State private var enableStreaming: Bool = true
    @State private var maxTokens: Double = 2000
    
    var body: some View {
        Form {
            Section("AI Provider") {
                TextField("API Key", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                    .help("Enter your AI provider API key")
                
                Picker("Model", selection: $modelSelection) {
                    Text("GPT-4").tag("GPT-4")
                    Text("GPT-3.5 Turbo").tag("GPT-3.5")
                    Text("Claude 3").tag("Claude-3")
                    Text("Local Model").tag("Local")
                }
                .pickerStyle(.menu)
            }
            
            Section("Features") {
                Toggle("Enable Voice Input", isOn: $enableVoice)
                Toggle("Enable Streaming Responses", isOn: $enableStreaming)
            }
            
            Section("Performance") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Max Tokens: \(Int(maxTokens))")
                        .font(.subheadline)
                    
                    Slider(value: $maxTokens, in: 500...4000, step: 100)
                }
            }
            
            Section("Conversation") {
                Button("Clear All Conversations") {
                    // Clear all conversations
                }
                .foregroundColor(.red)
                
                Button("Export Conversations") {
                    // Export functionality
                }
            }
            
            Section("About") {
                LabeledContent("Version", value: AIAssistantKit.version)
                LabeledContent("Build", value: "1.0.0")
                
                Button("View Documentation") {
                    // Open documentation
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#if DEBUG
struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView()
            .environmentObject(AppController.shared)
    }
}
#endif
