//
//  Services.swift
//  AIAssistantKit
//
//  Core service classes
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import Foundation

/// Conversation memory manager with enhanced persistence
public class ConversationMemoryManager {
    private var conversations: [String: [String]] = [:]
    private let storage = LocalStorageService.shared
    
    public init() {}
    
    public func clearConversation(_ id: String) {
        conversations.removeValue(forKey: id)
        if let uuid = UUID(uuidString: id) {
            try? storage.deleteConversation(id: uuid)
        }
    }
    
    public func addMessage(_ message: String, to conversationId: String) {
        if conversations[conversationId] == nil {
            conversations[conversationId] = []
        }
        conversations[conversationId]?.append(message)
        
        // Persist to storage
        persistConversation(conversationId)
    }
    
    public func getConversation(_ id: String) -> [String] {
        // Try to load from storage first
        if let uuid = UUID(uuidString: id),
           let thread = try? storage.loadConversation(id: uuid) {
            return thread.messages.map { $0.content }
        }
        return conversations[id] ?? []
    }
    
    private func persistConversation(_ id: String) {
        guard let uuid = UUID(uuidString: id),
              let messages = conversations[id] else { return }
        
        let messageObjects = messages.map { content in
            Message(content: content, isUser: true)
        }
        
        let thread = ConversationThread(
            id: uuid,
            messages: messageObjects
        )
        
        try? storage.saveConversation(thread)
    }
}

/// Context detector for code analysis with offline knowledge
public class ContextDetector {
    private let storage = LocalStorageService.shared
    
    public init() {}
    
    public func detectContext() -> AIContext? {
        // Try to enhance context with offline knowledge
        return nil
    }
    
    /// Search offline knowledge for relevant context
    public func searchKnowledge(query: String) -> [KnowledgeEntry] {
        return (try? storage.searchKnowledge(query: query)) ?? []
    }
    
    /// Get knowledge by category
    public func getKnowledge(category: KnowledgeCategory) -> [KnowledgeEntry] {
        let allEntries = (try? storage.loadAllKnowledgeEntries()) ?? []
        return allEntries.filter { $0.category == category }
    }
}

/// Voice input manager
public class VoiceInputManager {
    public init() {}
    
    public func startListening() {
        // Voice input implementation
    }
    
    public func stopListening() {
        // Stop voice input
    }
}
