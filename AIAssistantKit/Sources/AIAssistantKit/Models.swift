//
//  Models.swift
//  AIAssistantKit
//
//  Enhanced data models for AI assistant features
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import Foundation

// MARK: - Message Models

/// Enhanced message model with rich metadata
public struct Message: Identifiable, Codable {
    public let id: UUID
    public let content: String
    public let isUser: Bool
    public let timestamp: Date
    public var isFavorite: Bool
    public var codeBlocks: [CodeBlock]
    public var metadata: MessageMetadata
    
    public init(
        id: UUID = UUID(),
        content: String,
        isUser: Bool,
        timestamp: Date = Date(),
        isFavorite: Bool = false,
        codeBlocks: [CodeBlock] = [],
        metadata: MessageMetadata = MessageMetadata()
    ) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.isFavorite = isFavorite
        self.codeBlocks = codeBlocks
        self.metadata = metadata
    }
}

/// Message metadata for enhanced features
public struct MessageMetadata: Codable {
    public var reactions: [String: Int]
    public var edited: Bool
    public var editedAt: Date?
    public var tags: [String]
    
    public init(
        reactions: [String: Int] = [:],
        edited: Bool = false,
        editedAt: Date? = nil,
        tags: [String] = []
    ) {
        self.reactions = reactions
        self.edited = edited
        self.editedAt = editedAt
        self.tags = tags
    }
}

/// Code block with language detection
public struct CodeBlock: Identifiable, Codable {
    public let id: UUID
    public let code: String
    public let language: String
    public let lineNumbers: Bool
    
    public init(
        id: UUID = UUID(),
        code: String,
        language: String = "plain",
        lineNumbers: Bool = true
    ) {
        self.id = id
        self.code = code
        self.language = language
        self.lineNumbers = lineNumbers
    }
}

// MARK: - Conversation Models

/// Conversation thread with full history
public struct ConversationThread: Identifiable, Codable {
    public let id: UUID
    public var title: String
    public var messages: [Message]
    public let createdAt: Date
    public var updatedAt: Date
    public var tags: [String]
    public var isPinned: Bool
    
    public init(
        id: UUID = UUID(),
        title: String = "New Conversation",
        messages: [Message] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        tags: [String] = [],
        isPinned: Bool = false
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tags = tags
        self.isPinned = isPinned
    }
    
    public mutating func addMessage(_ message: Message) {
        messages.append(message)
        updatedAt = Date()
    }
}

// MARK: - Knowledge Base Models

/// Knowledge entry for offline storage
public struct KnowledgeEntry: Identifiable, Codable {
    public let id: UUID
    public let title: String
    public let content: String
    public let category: KnowledgeCategory
    public let tags: [String]
    public let createdAt: Date
    public var lastAccessed: Date
    public var accessCount: Int
    public var source: String?
    
    public init(
        id: UUID = UUID(),
        title: String,
        content: String,
        category: KnowledgeCategory,
        tags: [String] = [],
        createdAt: Date = Date(),
        lastAccessed: Date = Date(),
        accessCount: Int = 0,
        source: String? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.tags = tags
        self.createdAt = createdAt
        self.lastAccessed = lastAccessed
        self.accessCount = accessCount
        self.source = source
    }
}

/// Knowledge categories
public enum KnowledgeCategory: String, Codable, CaseIterable {
    case programming = "Programming"
    case documentation = "Documentation"
    case snippet = "Code Snippet"
    case reference = "Reference"
    case tutorial = "Tutorial"
    case general = "General"
}

// MARK: - Workspace Models

/// Project model for workspace management
public struct Project: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public var description: String
    public var path: String?
    public let createdAt: Date
    public var updatedAt: Date
    public var tasks: [Task]
    public var tags: [String]
    public var status: ProjectStatus
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        path: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        tasks: [Task] = [],
        tags: [String] = [],
        status: ProjectStatus = .active
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.path = path
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tasks = tasks
        self.tags = tags
        self.status = status
    }
}

/// Project status
public enum ProjectStatus: String, Codable, CaseIterable {
    case active = "Active"
    case paused = "Paused"
    case completed = "Completed"
    case archived = "Archived"
}

/// Task model for project management
public struct Task: Identifiable, Codable {
    public let id: UUID
    public var title: String
    public var description: String
    public var completed: Bool
    public let createdAt: Date
    public var completedAt: Date?
    public var priority: TaskPriority
    public var aiGenerated: Bool
    
    public init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        completed: Bool = false,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        priority: TaskPriority = .medium,
        aiGenerated: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.completed = completed
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.priority = priority
        self.aiGenerated = aiGenerated
    }
}

/// Task priority
public enum TaskPriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    
    public var color: String {
        switch self {
        case .low: return "gray"
        case .medium: return "blue"
        case .high: return "orange"
        case .urgent: return "red"
        }
    }
}

// MARK: - Suggested Prompts

/// Suggested prompt for quick actions
public struct SuggestedPrompt: Identifiable {
    public let id = UUID()
    public let text: String
    public let category: String
    public let icon: String
    
    public init(text: String, category: String, icon: String) {
        self.text = text
        self.category = category
        self.icon = icon
    }
}
