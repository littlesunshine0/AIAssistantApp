//
//  AIAssistantChatView.swift
//  AIAssistantKit
//
//  AI Chat interface view
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import SwiftUI

/// Configuration for chat view
public struct ChatConfiguration {
    public static let `default` = ChatConfiguration()
    
    public init() {}
}

/// AI Assistant chat view component
public struct AIAssistantChatView: View {
    let provider: AIProvider
    @Binding var isExpanded: Bool
    @Binding var height: CGFloat
    let conversationId: String
    let configuration: ChatConfiguration
    
    @State private var inputText: String = ""
    @State private var messages: [(String, Bool)] = [] // (message, isUser)
    @State private var isProcessing: Bool = false
    
    public init(
        provider: AIProvider,
        isExpanded: Binding<Bool>,
        height: Binding<CGFloat>,
        conversationId: String,
        configuration: ChatConfiguration
    ) {
        self.provider = provider
        self._isExpanded = isExpanded
        self._height = height
        self.conversationId = conversationId
        self.configuration = configuration
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Messages area
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(messages.enumerated()), id: \.offset) { index, item in
                        MessageBubble(message: item.0, isUser: item.1)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Divider()
            
            // Input area
            HStack(spacing: 12) {
                TextField("Ask AI anything...", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isProcessing)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(inputText.isEmpty ? .gray : .blue)
                }
                .disabled(inputText.isEmpty || isProcessing)
                .buttonStyle(.borderless)
            }
            .padding()
            .background(Color(.controlBackgroundColor))
        }
        .frame(height: height)
    }
    
    private func sendMessage() {
        let userMessage = inputText
        messages.append((userMessage, true))
        inputText = ""
        isProcessing = true
        
        Task {
            do {
                let response = try await provider.ask(query: userMessage, context: nil)
                await MainActor.run {
                    messages.append((response.message, false))
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    messages.append(("Error: \(error.localizedDescription)", false))
                    isProcessing = false
                }
            }
        }
    }
}

private struct MessageBubble: View {
    let message: String
    let isUser: Bool
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            Text(message)
                .padding(12)
                .background(isUser ? Color.blue : Color(.controlBackgroundColor))
                .foregroundColor(isUser ? .white : .primary)
                .cornerRadius(12)
                .frame(maxWidth: .infinity * 0.7, alignment: isUser ? .trailing : .leading)
            
            if !isUser { Spacer() }
        }
    }
}
