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
    @State private var showHistory = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            chatHeader
            
            Divider()
            
            // Enhanced chat interface with all new features
            EnhancedChatView(
                provider: controller.aiProvider,
                isExpanded: $controller.isChatExpanded,
                height: $controller.chatHeight,
                conversationId: controller.currentConversationId
            )
        }
        .navigationTitle("AI Chat")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: { showHistory = true }) {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                
                Button(action: controller.createNewConversation) {
                    Label("New Conversation", systemImage: "plus.message")
                }
                
                Button(action: controller.clearCurrentConversation) {
                    Label("Clear", systemImage: "trash")
                }
            }
        }
        .sheet(isPresented: $showHistory) {
            ConversationHistoryView()
                .frame(width: 800, height: 600)
        }
    }
    
    // MARK: - Header
    
    private var chatHeader: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundColor(.purple)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Enhanced AI Chat")
                    .font(.headline)
                
                Text("Advanced features: streaming, code highlighting, offline knowledge")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Feature badges
            HStack(spacing: 8) {
                FeatureBadge(icon: "bolt.fill", color: .orange, text: "Streaming")
                FeatureBadge(icon: "text.quote", color: .blue, text: "Markdown")
                FeatureBadge(icon: "chevron.left.forwardslash.chevron.right", color: .green, text: "Code")
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}

// MARK: - Feature Badge

struct FeatureBadge: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2)
        }
        .foregroundColor(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.15))
        .cornerRadius(6)
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
