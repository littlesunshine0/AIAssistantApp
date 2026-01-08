//
//  ChatTabView.swift
//  AIAssistantApp
//
//  Chat interface tab view
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import SwiftUI
import AIAssistantKit

/// Chat tab view providing the AI chat interface.
struct ChatTabView: View {
    @EnvironmentObject var controller: AppController
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            chatHeader
            
            Divider()
            
            // Chat interface
            AIAssistantChatView(
                provider: controller.aiProvider,
                isExpanded: $controller.isChatExpanded,
                height: $controller.chatHeight,
                conversationId: controller.currentConversationId,
                configuration: .default
            )
        }
        .navigationTitle("AI Chat")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: controller.createNewConversation) {
                    Label("New Conversation", systemImage: "plus.message")
                }
                
                Button(action: controller.clearCurrentConversation) {
                    Label("Clear", systemImage: "trash")
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var chatHeader: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundColor(.purple)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("AI Assistant Chat")
                    .font(.headline)
                
                Text("Ask anything or get help with your code")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Suggestions indicator
            if !controller.aiProvider.suggestions.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text("\(controller.aiProvider.suggestions.count) suggestions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
    }
}

// MARK: - Preview

#if DEBUG
struct ChatTabView_Previews: PreviewProvider {
    static var previews: some View {
        ChatTabView()
            .environmentObject(AppController.shared)
    }
}
#endif
