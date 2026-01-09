//
//  EnhancedChatView.swift
//  AIAssistantKit
//
//  Enhanced AI chat interface with advanced features
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import SwiftUI

/// Enhanced AI Assistant chat view with offline knowledge and rich features
public struct EnhancedChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @Binding var isExpanded: Bool
    @Binding var height: CGFloat
    
    public init(
        provider: AIProvider,
        isExpanded: Binding<Bool>,
        height: Binding<CGFloat>,
        conversationId: UUID = UUID()
    ) {
        self._viewModel = StateObject(wrappedValue: ChatViewModel(provider: provider, conversationId: conversationId))
        self._isExpanded = isExpanded
        self._height = height
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Messages area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(viewModel.messages) { message in
                            EnhancedMessageBubble(
                                message: message,
                                onToggleFavorite: { viewModel.toggleFavorite(message.id) },
                                onDelete: { viewModel.deleteMessage(message.id) }
                            )
                            .id(message.id)
                        }
                        
                        // Streaming indicator
                        if viewModel.isStreaming && !viewModel.streamingText.isEmpty {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(viewModel.streamingText)
                                        .textSelection(.enabled)
                                    
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 6, height: 6)
                                            .animation(.easeInOut(duration: 0.6).repeatForever(), value: viewModel.isStreaming)
                                        
                                        Text("AI is typing...")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(12)
                                .background(Color(.controlBackgroundColor))
                                .cornerRadius(12)
                                .frame(maxWidth: .infinity * 0.75, alignment: .leading)
                                
                                Spacer()
                            }
                            .id("streaming")
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.isStreaming) { _ in
                    if viewModel.isStreaming {
                        withAnimation {
                            proxy.scrollTo("streaming", anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // Suggested prompts (when no messages)
            if viewModel.messages.isEmpty || viewModel.showSuggestions {
                suggestedPromptsView
            }
            
            // Input area
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    // Suggestions button
                    Button(action: { viewModel.showSuggestions.toggle() }) {
                        Image(systemName: viewModel.showSuggestions ? "lightbulb.fill" : "lightbulb")
                            .foregroundColor(.yellow)
                    }
                    .buttonStyle(.borderless)
                    .help("Toggle suggestions")
                    
                    // Text input
                    TextField("Ask AI anything...", text: $viewModel.inputText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...5)
                        .disabled(viewModel.isProcessing)
                        .onSubmit {
                            Task { await viewModel.sendMessage() }
                        }
                    
                    // Send button
                    Button(action: { Task { await viewModel.sendMessage() } }) {
                        Image(systemName: viewModel.isProcessing ? "hourglass" : "paperplane.fill")
                            .foregroundColor(viewModel.inputText.isEmpty ? .gray : .blue)
                    }
                    .disabled(viewModel.inputText.isEmpty || viewModel.isProcessing)
                    .buttonStyle(.borderless)
                    
                    // Clear button
                    if !viewModel.messages.isEmpty {
                        Button(action: { viewModel.clearMessages() }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red.opacity(0.7))
                        }
                        .buttonStyle(.borderless)
                        .help("Clear conversation")
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Message count and favorites
                if !viewModel.messages.isEmpty {
                    HStack {
                        Text("\(viewModel.messages.count) messages")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        let favoriteCount = viewModel.messages.filter { $0.isFavorite }.count
                        if favoriteCount > 0 {
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("\(favoriteCount)")
                            }
                            .font(.caption2)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                }
            }
            .padding(.bottom, 8)
            .background(Color(.controlBackgroundColor))
        }
        .frame(height: height)
    }
    
    private var suggestedPromptsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.suggestedPrompts) { prompt in
                    Button(action: { viewModel.useSuggestedPrompt(prompt) }) {
                        HStack(spacing: 6) {
                            Image(systemName: prompt.icon)
                                .font(.caption)
                            Text(prompt.text)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(16)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.controlBackgroundColor).opacity(0.5))
    }
}
