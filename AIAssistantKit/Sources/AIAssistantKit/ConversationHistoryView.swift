//
//  ConversationHistoryView.swift
//  AIAssistantKit
//
//  Conversation history browser with search and management
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import SwiftUI

/// Conversation history browser view
public struct ConversationHistoryView: View {
    @State private var conversations: [ConversationThread] = []
    @State private var searchQuery = ""
    @State private var selectedConversation: ConversationThread?
    @State private var isLoading = false
    
    private let storage = LocalStorageService.shared
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView {
            conversationList
        } detail: {
            if let conversation = selectedConversation {
                conversationDetail(conversation)
            } else {
                emptyState
            }
        }
        .navigationTitle("Conversation History")
        .searchable(text: $searchQuery, prompt: "Search conversations...")
        .onAppear {
            loadConversations()
        }
    }
    
    private var conversationList: some View {
        List(filteredConversations, selection: $selectedConversation) { conversation in
            NavigationLink(value: conversation) {
                ConversationRow(conversation: conversation)
            }
            .contextMenu {
                Button(role: .destructive) {
                    deleteConversation(conversation.id)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                
                Button {
                    exportConversation(conversation)
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            }
        }
        .listStyle(.sidebar)
        .overlay {
            if isLoading {
                ProgressView("Loading conversations...")
            }
        }
    }
    
    private func conversationDetail(_ conversation: ConversationThread) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(conversation.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        if conversation.isPinned {
                            Image(systemName: "pin.fill")
                                .foregroundColor(.orange)
                        }
                    }
                    
                    HStack {
                        Label("\(conversation.messages.count) messages", systemImage: "message")
                        
                        Spacer()
                        
                        Text(conversation.updatedAt.formatted(date: .abbreviated, time: .shortened))
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    if !conversation.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(conversation.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.controlBackgroundColor).opacity(0.5))
                .cornerRadius(12)
                
                Divider()
                
                // Messages
                ForEach(conversation.messages) { message in
                    EnhancedMessageBubble(
                        message: message,
                        onToggleFavorite: { },
                        onDelete: { }
                    )
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem {
                Menu {
                    Button {
                        exportConversation(conversation)
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive) {
                        deleteConversation(conversation.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Conversation Selected")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Select a conversation from the sidebar to view its details")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var filteredConversations: [ConversationThread] {
        if searchQuery.isEmpty {
            return conversations
        }
        
        return conversations.filter { conversation in
            conversation.title.localizedCaseInsensitiveContains(searchQuery) ||
            conversation.messages.contains { $0.content.localizedCaseInsensitiveContains(searchQuery) } ||
            conversation.tags.contains { $0.localizedCaseInsensitiveContains(searchQuery) }
        }
    }
    
    private func loadConversations() {
        isLoading = true
        Task {
            do {
                conversations = try storage.loadAllConversations()
            } catch {
                print("Failed to load conversations: \(error)")
            }
            isLoading = false
        }
    }
    
    private func deleteConversation(_ id: UUID) {
        Task {
            try? storage.deleteConversation(id: id)
            conversations.removeAll { $0.id == id }
            if selectedConversation?.id == id {
                selectedConversation = nil
            }
        }
    }
    
    private func exportConversation(_ conversation: ConversationThread) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "\(conversation.title).json"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                do {
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    let data = try encoder.encode(conversation)
                    try data.write(to: url)
                } catch {
                    print("Failed to export: \(error)")
                }
            }
        }
    }
}

// MARK: - Conversation Row

struct ConversationRow: View {
    let conversation: ConversationThread
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(conversation.title)
                    .font(.headline)
                    .lineLimit(1)
                
                if conversation.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            if let firstUserMessage = conversation.messages.first(where: { $0.isUser }) {
                Text(firstUserMessage.content)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Label("\(conversation.messages.count)", systemImage: "message")
                
                Text("•")
                
                Text(conversation.updatedAt.formatted(date: .abbreviated, time: .omitted))
            }
            .font(.caption2)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
