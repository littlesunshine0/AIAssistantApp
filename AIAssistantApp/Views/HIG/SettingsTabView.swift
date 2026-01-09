//
//  SettingsTabView.swift
//  AIAssistantApp
//
//  Settings interface tab view
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import SwiftUI
import AIAssistantKit
import UniformTypeIdentifiers

/// Settings tab view for application configuration.
struct SettingsTabView: View {
    @EnvironmentObject var controller: AppController
    @State private var apiKey: String = ""
    @State private var modelSelection: String = "GPT-4"
    @State private var enableVoice: Bool = true
    @State private var enableStreaming: Bool = true
    @State private var maxTokens: Double = 2000
    @State private var showExportDialog = false
    @State private var showImportDialog = false
    
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
            
            Section("Enhanced Features") {
                Toggle("Enable Voice Input", isOn: $enableVoice)
                Toggle("Enable Streaming Responses", isOn: $enableStreaming)
                Toggle("Code Syntax Highlighting", isOn: .constant(true))
                    .disabled(true)
                Toggle("Markdown Rendering", isOn: .constant(true))
                    .disabled(true)
                Toggle("Offline Knowledge Base", isOn: .constant(true))
                    .disabled(true)
            }
            
            Section("Performance") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Max Tokens: \(Int(maxTokens))")
                        .font(.subheadline)
                    
                    Slider(value: $maxTokens, in: 500...4000, step: 100)
                }
            }
            
            Section("Data Management") {
                LabeledContent("Knowledge Entries", value: "\(knowledgeCount)")
                LabeledContent("Total Conversations", value: "\(conversationCount)")
                
                Button("Export Conversations") {
                    showExportDialog = true
                }
                
                Button("Clear All Data") {
                    clearAllConversations()
                }
                .foregroundColor(.red)
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
        .fileExporter(
            isPresented: $showExportDialog,
            document: ConversationExportDocument(),
            contentType: .json,
            defaultFilename: "conversations-export.json"
        ) { result in
            handleExport(result)
        }
    }
    
    private var knowledgeCount: Int {
        (try? LocalStorageService.shared.loadAllKnowledgeEntries().count) ?? 0
    }
    
    private var conversationCount: Int {
        (try? LocalStorageService.shared.loadAllConversations().count) ?? 0
    }
    
    private func clearAllConversations() {
        // Show confirmation dialog
        let alert = NSAlert()
        alert.messageText = "Clear All Data?"
        alert.informativeText = "This action cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Clear")
        
        if alert.runModal() == .alertSecondButtonReturn {
            // Clear all
        }
    }
    
    private func handleExport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            print("Exported to: \(url)")
        case .failure(let error):
            print("Export failed: \(error)")
        }
    }
}

// MARK: - Export Document

struct ConversationExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    init() {}
    
    init(configuration: ReadConfiguration) throws {}
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let storage = LocalStorageService.shared
        let conversations = try storage.loadAllConversations()
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(conversations)
        
        return FileWrapper(regularFileWithContents: data)
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
