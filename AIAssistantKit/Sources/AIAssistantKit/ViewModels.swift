//
//  ViewModels.swift
//  AIAssistantKit
//
//  View models for state management
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - Chat View Model

/// View model for chat functionality with advanced features
@MainActor
public class ChatViewModel: ObservableObject {
    @Published public var messages: [Message] = []
    @Published public var isProcessing: Bool = false
    @Published public var inputText: String = ""
    @Published public var streamingText: String = ""
    @Published public var isStreaming: Bool = false
    @Published public var suggestedPrompts: [SuggestedPrompt] = []
    @Published public var showSuggestions: Bool = false
    
    private let provider: AIProvider
    private let storage = LocalStorageService.shared
    public let conversationId: UUID
    
    public init(provider: AIProvider, conversationId: UUID = UUID()) {
        self.provider = provider
        self.conversationId = conversationId
        loadSuggestedPrompts()
        loadConversation()
    }
    
    public func sendMessage(_ text: String? = nil) async {
        let messageText = text ?? inputText
        guard !messageText.isEmpty else { return }
        
        // Add user message
        let userMessage = Message(content: messageText, isUser: true)
        messages.append(userMessage)
        inputText = ""
        isProcessing = true
        
        // Extract code blocks
        let codeBlocks = extractCodeBlocks(from: messageText)
        
        do {
            // Use streaming if available
            isStreaming = true
            streamingText = ""
            
            var fullResponse = ""
            let stream = provider.askStreaming(query: messageText, context: nil)
            
            for try await chunk in stream {
                streamingText += chunk
                fullResponse += chunk
            }
            
            isStreaming = false
            
            // Create AI message with code blocks
            let aiMessage = Message(
                content: fullResponse,
                isUser: false,
                codeBlocks: extractCodeBlocks(from: fullResponse)
            )
            messages.append(aiMessage)
            
            // Save conversation
            await saveConversation()
            
        } catch {
            let errorMessage = Message(
                content: "Error: \(error.localizedDescription)",
                isUser: false
            )
            messages.append(errorMessage)
        }
        
        isProcessing = false
        streamingText = ""
    }
    
    public func toggleFavorite(_ messageId: UUID) {
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            messages[index].isFavorite.toggle()
            Task { await saveConversation() }
        }
    }
    
    public func deleteMessage(_ messageId: UUID) {
        messages.removeAll { $0.id == messageId }
        Task { await saveConversation() }
    }
    
    public func clearMessages() {
        messages.removeAll()
        Task { await saveConversation() }
    }
    
    public func useSuggestedPrompt(_ prompt: SuggestedPrompt) {
        inputText = prompt.text
        showSuggestions = false
    }
    
    private func loadConversation() {
        Task {
            if let conversation = try? storage.loadConversation(id: conversationId) {
                messages = conversation.messages
            }
        }
    }
    
    private func saveConversation() async {
        var conversation = ConversationThread(
            id: conversationId,
            messages: messages
        )
        
        // Update title based on first message
        if let firstMessage = messages.first(where: { $0.isUser }) {
            let title = String(firstMessage.content.prefix(50))
            conversation.title = title
        }
        
        try? storage.saveConversation(conversation)
    }
    
    private func loadSuggestedPrompts() {
        suggestedPrompts = [
            SuggestedPrompt(text: "Explain this code to me", category: "Code", icon: "doc.text"),
            SuggestedPrompt(text: "Generate a Swift function for...", category: "Generate", icon: "wand.and.stars"),
            SuggestedPrompt(text: "Refactor this code", category: "Refactor", icon: "arrow.triangle.2.circlepath"),
            SuggestedPrompt(text: "Write unit tests for...", category: "Testing", icon: "checkmark.circle"),
            SuggestedPrompt(text: "Find bugs in this code", category: "Debug", icon: "ant.circle"),
            SuggestedPrompt(text: "Optimize performance of...", category: "Optimize", icon: "speedometer"),
            SuggestedPrompt(text: "Create documentation for...", category: "Docs", icon: "book"),
            SuggestedPrompt(text: "Convert this to async/await", category: "Async", icon: "clock.arrow.circlepath")
        ]
    }
    
    private func extractCodeBlocks(from text: String) -> [CodeBlock] {
        var blocks: [CodeBlock] = []
        let pattern = "```(\\w+)?\\n([\\s\\S]*?)```"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            
            for match in matches {
                let languageRange = match.range(at: 1)
                let codeRange = match.range(at: 2)
                
                let language = languageRange.location != NSNotFound
                    ? String(text[Range(languageRange, in: text)!])
                    : "plain"
                
                if codeRange.location != NSNotFound,
                   let range = Range(codeRange, in: text) {
                    let code = String(text[range])
                    blocks.append(CodeBlock(code: code, language: language))
                }
            }
        }
        
        return blocks
    }
}

// MARK: - Knowledge Base View Model

/// View model for knowledge base management
@MainActor
public class KnowledgeBaseViewModel: ObservableObject {
    @Published public var entries: [KnowledgeEntry] = []
    @Published public var searchQuery: String = ""
    @Published public var selectedCategory: KnowledgeCategory?
    @Published public var isLoading: Bool = false
    
    private let storage = LocalStorageService.shared
    
    public init() {
        loadEntries()
    }
    
    public func loadEntries() {
        isLoading = true
        Task {
            do {
                var loadedEntries = try storage.loadAllKnowledgeEntries()
                
                // Filter by category if selected
                if let category = selectedCategory {
                    loadedEntries = loadedEntries.filter { $0.category == category }
                }
                
                // Apply search filter
                if !searchQuery.isEmpty {
                    loadedEntries = try storage.searchKnowledge(query: searchQuery)
                }
                
                entries = loadedEntries
            } catch {
                print("Failed to load knowledge entries: \(error)")
            }
            isLoading = false
        }
    }
    
    public func addEntry(_ entry: KnowledgeEntry) {
        Task {
            do {
                try storage.saveKnowledgeEntry(entry)
                await loadEntries()
            } catch {
                print("Failed to save entry: \(error)")
            }
        }
    }
    
    public func deleteEntry(_ id: UUID) {
        Task {
            do {
                try storage.deleteKnowledgeEntry(id: id)
                entries.removeAll { $0.id == id }
            } catch {
                print("Failed to delete entry: \(error)")
            }
        }
    }
    
    public func incrementAccess(_ id: UUID) {
        if let index = entries.firstIndex(where: { $0.id == id }) {
            entries[index].lastAccessed = Date()
            entries[index].accessCount += 1
            
            Task {
                try? storage.saveKnowledgeEntry(entries[index])
            }
        }
    }
}

// MARK: - Workspace View Model

/// View model for workspace and project management
@MainActor
public class WorkspaceViewModel: ObservableObject {
    @Published public var projects: [Project] = []
    @Published public var selectedProject: Project?
    @Published public var isLoading: Bool = false
    
    private let storage = LocalStorageService.shared
    
    public init() {
        loadProjects()
    }
    
    public func loadProjects() {
        isLoading = true
        Task {
            do {
                projects = try storage.loadAllProjects()
            } catch {
                print("Failed to load projects: \(error)")
            }
            isLoading = false
        }
    }
    
    public func addProject(_ project: Project) {
        Task {
            do {
                try storage.saveProject(project)
                projects.append(project)
            } catch {
                print("Failed to save project: \(error)")
            }
        }
    }
    
    public func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            Task {
                try? storage.saveProject(project)
            }
        }
    }
    
    public func deleteProject(_ id: UUID) {
        Task {
            do {
                try storage.deleteProject(id: id)
                projects.removeAll { $0.id == id }
            } catch {
                print("Failed to delete project: \(error)")
            }
        }
    }
    
    public func addTaskToProject(_ task: Task, projectId: UUID) {
        if let index = projects.firstIndex(where: { $0.id == projectId }) {
            projects[index].tasks.append(task)
            projects[index].updatedAt = Date()
            updateProject(projects[index])
        }
    }
    
    public func toggleTaskCompletion(_ taskId: UUID, projectId: UUID) {
        if let projectIndex = projects.firstIndex(where: { $0.id == projectId }),
           let taskIndex = projects[projectIndex].tasks.firstIndex(where: { $0.id == taskId }) {
            projects[projectIndex].tasks[taskIndex].completed.toggle()
            projects[projectIndex].tasks[taskIndex].completedAt = projects[projectIndex].tasks[taskIndex].completed ? Date() : nil
            updateProject(projects[projectIndex])
        }
    }
}
