//
//  AIProvider.swift
//  AIAssistantKit
//
//  AI Provider protocol definition
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import Foundation

/// Context information for AI requests
public struct AIContext {
    public let currentFile: FileContext?
    public let selectedText: String?
    public let projectContext: ProjectContext?
    
    public init(currentFile: FileContext? = nil, selectedText: String? = nil, projectContext: ProjectContext? = nil) {
        self.currentFile = currentFile
        self.selectedText = selectedText
        self.projectContext = projectContext
    }
}

/// File context information
public struct FileContext {
    public let path: String
    public let language: String
    
    public init(path: String, language: String) {
        self.path = path
        self.language = language
    }
}

/// Project context information
public struct ProjectContext {
    public let name: String
    public let type: String
    
    public init(name: String, type: String) {
        self.name = name
        self.type = type
    }
}

/// AI response structure
public struct AIResponse {
    public let message: String
    public let canGenerate: Bool
    public let suggestedActions: [String]
    
    public init(message: String, canGenerate: Bool, suggestedActions: [String]) {
        self.message = message
        self.canGenerate = canGenerate
        self.suggestedActions = suggestedActions
    }
}

/// AI suggestion item
public struct AISuggestion: Identifiable {
    public let id = UUID()
    public let title: String
    public let icon: String
    
    public init(title: String, icon: String) {
        self.title = title
        self.icon = icon
    }
}

/// AI Provider protocol
public protocol AIProvider {
    var suggestions: [AISuggestion] { get }
    
    func ask(query: String, context: AIContext?) async throws -> AIResponse
    func askStreaming(query: String, context: AIContext?) -> AsyncThrowingStream<String, Error>
}
