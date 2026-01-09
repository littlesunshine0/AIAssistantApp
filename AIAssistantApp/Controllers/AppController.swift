//
//  AppController.swift
//  AIAssistantApp
//
//  Master controller coordinating all app services and state
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import SwiftUI
import AIAssistantKit
import Combine

/// Master controller managing the entire application state and coordination.
///
/// `AppController` acts as the central coordinator for the AI Assistant application,
/// managing navigation, AI providers, services, and global state.
@MainActor
final class AppController: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = AppController()
    
    // MARK: - Published State
    
    /// Current selected tab in the master view
    @Published var selectedTab: MasterTab = .chat
    
    /// Whether to show the about dialog
    @Published var showAbout: Bool = false
    
    /// AI provider instance
    @Published var aiProvider: DefaultAIProvider
    
    /// Chat expansion state
    @Published var isChatExpanded: Bool = true
    
    /// Chat panel height
    @Published var chatHeight: CGFloat = 400
    
    /// Current conversation ID
    @Published var currentConversationId: UUID = UUID()
    
    // MARK: - Services
    
    /// Conversation memory manager
    let memoryManager = ConversationMemoryManager()
    
    /// Context detector
    let contextDetector = ContextDetector()
    
    /// Voice input manager
    let voiceManager = VoiceInputManager()
    
    // MARK: - Initialization
    
    private init() {
        self.aiProvider = DefaultAIProvider()
    }
    
    // MARK: - Actions
    
    func switchTab(_ tab: MasterTab) {
        selectedTab = tab
    }
    
    func createNewConversation() {
        currentConversationId = UUID()
        isChatExpanded = true
    }
    
    func clearCurrentConversation() {
        memoryManager.clearConversation(currentConversationId.uuidString)
    }
}

// MARK: - Master Tab Enum

enum MasterTab: String, CaseIterable, Identifiable {
    case chat = "Chat"
    case workspace = "Workspace"
    case settings = "Settings"
    case about = "About"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .chat: return "message.fill"
        case .workspace: return "square.grid.2x2.fill"
        case .settings: return "gear"
        case .about: return "info.circle"
        }
    }
}
