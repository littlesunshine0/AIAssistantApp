//
//  EnhancedChatController.swift
//  AIAssistantApp
//
//  Example controller showing integration of AIAssistantKit and HIG packages
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import SwiftUI
import AIAssistantKit
// HIG package can be imported when using HIG documentation features
// import HIGPackage

/// Enhanced chat controller demonstrating integration of both packages
///
/// This controller shows how to utilize AIAssistantKit for AI functionality
/// while following HIG design principles from the HIG package.
@MainActor
final class EnhancedChatController: ObservableObject {
    
    // MARK: - AIAssistantKit Integration
    
    /// AI provider from AIAssistantKit (using protocol for flexibility)
    @Published var aiProvider: any AIProvider
    
    /// Conversation memory manager from AIAssistantKit
    let memoryManager = ConversationMemoryManager()
    
    /// Context detector from AIAssistantKit
    let contextDetector = ContextDetector()
    
    /// Voice input manager from AIAssistantKit
    let voiceManager = VoiceInputManager()
    
    // MARK: - HIG Integration
    
    /// Following HIG principles: State management
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    /// Following HIG principles: Accessibility
    @Published var useReducedMotion: Bool = false
    @Published var useLargeText: Bool = false
    
    // MARK: - Initialization
    
    init() {
        self.aiProvider = DefaultAIProvider()
        
        // Load HIG documentation if needed
        // self.loadHIGDocumentation()
    }
    
    // MARK: - AI Operations (using AIAssistantKit)
    
    /// Send a message using AIAssistantKit provider
    func sendMessage(_ message: String, in conversationId: String) async {
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            // Store in memory
            memoryManager.addMessage(message, to: conversationId)
            
            // Detect context
            let context = contextDetector.detectContext()
            
            // Ask AI
            let response = try await aiProvider.ask(query: message, context: context)
            
            // Store response
            memoryManager.addMessage(response.message, to: conversationId)
            
        } catch {
            await handleError(error)
        }
    }
    
    /// Stream a response using AIAssistantKit
    func streamMessage(_ message: String, in conversationId: String) -> AsyncThrowingStream<String, Error> {
        memoryManager.addMessage(message, to: conversationId)
        let context = contextDetector.detectContext()
        return aiProvider.askStreaming(query: message, context: context)
    }
    
    // MARK: - HIG Principles Implementation
    
    /// Error handling following HIG guidelines
    private func handleError(_ error: Error) async {
        errorMessage = error.localizedDescription
        showError = true
        
        // HIG: Provide clear, actionable error messages
        // HIG: Use system-standard alerts
    }
    
    /// Clear conversation (with user confirmation per HIG)
    func clearConversation(_ id: String, confirmed: Bool = false) {
        guard confirmed else {
            // HIG: Require confirmation for destructive actions
            return
        }
        
        memoryManager.clearConversation(id)
    }
    
    // MARK: - Voice Integration
    
    func startVoiceInput() {
        // HIG: Provide clear feedback for voice activation
        voiceManager.startListening()
    }
    
    func stopVoiceInput() {
        voiceManager.stopListening()
    }
    
    // MARK: - HIG Documentation Integration (Optional)
    
    /*
    private func loadHIGDocumentation() {
        // Example: Load HIG documentation from HIGPackage
        // if let url = Bundle.main.url(forResource: "hig_combined", withExtension: "json") {
        //     do {
        //         let document = try HIGDataLoader.load(from: url)
        //         let topics = HIGDataLoader.topics(for: "Accessibility", in: document)
        //         // Use HIG topics to guide implementation
        //     } catch {
        //         print("Failed to load HIG documentation: \(error)")
        //     }
        // }
    }
    */
}

// MARK: - Example Usage in Views

/*
struct ExampleIntegrationView: View {
    @StateObject private var controller = EnhancedChatController()
    @State private var inputText = ""
    
    var body: some View {
        VStack {
            // Use AIAssistantKit chat view
            AIAssistantChatView(
                provider: controller.aiProvider,
                isExpanded: .constant(true),
                height: .constant(400),
                conversationId: "main",
                configuration: .default
            )
            
            // HIG-compliant input area
            HStack {
                TextField("Message", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                
                Button("Send") {
                    Task {
                        await controller.sendMessage(inputText, in: "main")
                        inputText = ""
                    }
                }
                .disabled(controller.isProcessing)
            }
            .padding()
        }
        .alert("Error", isPresented: $controller.showError) {
            Button("OK") { }
        } message: {
            Text(controller.errorMessage ?? "Unknown error")
        }
    }
}
*/
