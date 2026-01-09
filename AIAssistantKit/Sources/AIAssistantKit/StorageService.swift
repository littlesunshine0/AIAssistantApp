//
//  StorageService.swift
//  AIAssistantKit
//
//  Local storage service for offline knowledge and persistence
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import Foundation

/// Local storage service for persistent data
public class LocalStorageService {
    public static let shared = LocalStorageService()
    
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private lazy var documentsDirectory: URL = {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }()
    
    private lazy var storageDirectory: URL = {
        let dir = documentsDirectory.appendingPathComponent("AIAssistant", isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()
    
    public init() {
        encoder.outputFormatting = .prettyPrinted
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Conversations
    
    public func saveConversation(_ conversation: ConversationThread) throws {
        let url = storageDirectory.appendingPathComponent("conversations/\(conversation.id.uuidString).json")
        try? fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let data = try encoder.encode(conversation)
        try data.write(to: url)
    }
    
    public func loadConversation(id: UUID) throws -> ConversationThread? {
        let url = storageDirectory.appendingPathComponent("conversations/\(id.uuidString).json")
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        let data = try Data(contentsOf: url)
        return try decoder.decode(ConversationThread.self, from: data)
    }
    
    public func loadAllConversations() throws -> [ConversationThread] {
        let conversationsDir = storageDirectory.appendingPathComponent("conversations")
        guard fileManager.fileExists(atPath: conversationsDir.path) else { return [] }
        
        let urls = try fileManager.contentsOfDirectory(at: conversationsDir, includingPropertiesForKeys: nil)
        return try urls.compactMap { url in
            let data = try Data(contentsOf: url)
            return try? decoder.decode(ConversationThread.self, from: data)
        }.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    public func deleteConversation(id: UUID) throws {
        let url = storageDirectory.appendingPathComponent("conversations/\(id.uuidString).json")
        try fileManager.removeItem(at: url)
    }
    
    // MARK: - Knowledge Base
    
    public func saveKnowledgeEntry(_ entry: KnowledgeEntry) throws {
        let url = storageDirectory.appendingPathComponent("knowledge/\(entry.id.uuidString).json")
        try? fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let data = try encoder.encode(entry)
        try data.write(to: url)
    }
    
    public func loadKnowledgeEntry(id: UUID) throws -> KnowledgeEntry? {
        let url = storageDirectory.appendingPathComponent("knowledge/\(id.uuidString).json")
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        let data = try Data(contentsOf: url)
        return try decoder.decode(KnowledgeEntry.self, from: data)
    }
    
    public func loadAllKnowledgeEntries() throws -> [KnowledgeEntry] {
        let knowledgeDir = storageDirectory.appendingPathComponent("knowledge")
        guard fileManager.fileExists(atPath: knowledgeDir.path) else { return [] }
        
        let urls = try fileManager.contentsOfDirectory(at: knowledgeDir, includingPropertiesForKeys: nil)
        return try urls.compactMap { url in
            let data = try Data(contentsOf: url)
            return try? decoder.decode(KnowledgeEntry.self, from: data)
        }
    }
    
    public func deleteKnowledgeEntry(id: UUID) throws {
        let url = storageDirectory.appendingPathComponent("knowledge/\(id.uuidString).json")
        try fileManager.removeItem(at: url)
    }
    
    public func searchKnowledge(query: String) throws -> [KnowledgeEntry] {
        let entries = try loadAllKnowledgeEntries()
        let lowercaseQuery = query.lowercased()
        
        return entries.filter { entry in
            entry.title.lowercased().contains(lowercaseQuery) ||
            entry.content.lowercased().contains(lowercaseQuery) ||
            entry.tags.contains { $0.lowercased().contains(lowercaseQuery) }
        }.sorted { $0.lastAccessed > $1.lastAccessed }
    }
    
    // MARK: - Projects
    
    public func saveProject(_ project: Project) throws {
        let url = storageDirectory.appendingPathComponent("projects/\(project.id.uuidString).json")
        try? fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let data = try encoder.encode(project)
        try data.write(to: url)
    }
    
    public func loadProject(id: UUID) throws -> Project? {
        let url = storageDirectory.appendingPathComponent("projects/\(id.uuidString).json")
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        let data = try Data(contentsOf: url)
        return try decoder.decode(Project.self, from: data)
    }
    
    public func loadAllProjects() throws -> [Project] {
        let projectsDir = storageDirectory.appendingPathComponent("projects")
        guard fileManager.fileExists(atPath: projectsDir.path) else { return [] }
        
        let urls = try fileManager.contentsOfDirectory(at: projectsDir, includingPropertiesForKeys: nil)
        return try urls.compactMap { url in
            let data = try Data(contentsOf: url)
            return try? decoder.decode(Project.self, from: data)
        }.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    public func deleteProject(id: UUID) throws {
        let url = storageDirectory.appendingPathComponent("projects/\(id.uuidString).json")
        try fileManager.removeItem(at: url)
    }
    
    // MARK: - Export/Import
    
    public func exportConversations(to url: URL) throws {
        let conversations = try loadAllConversations()
        let data = try encoder.encode(conversations)
        try data.write(to: url)
    }
    
    public func importConversations(from url: URL) throws {
        let data = try Data(contentsOf: url)
        let conversations = try decoder.decode([ConversationThread].self, from: data)
        for conversation in conversations {
            try saveConversation(conversation)
        }
    }
}
