# AIAssistantApp Integration Guide

This document describes how AIAssistantKit and HIG packages are integrated into the AIAssistantApp.

## Package Structure

### AIAssistantKit
Located in `AIAssistantKit/` directory, this package provides:
- **Core AI Provider Protocol**: `AIProvider` for implementing custom AI backends
- **Data Models**: `AIContext`, `AIResponse`, `AISuggestion`, etc.
- **Service Classes**: `ConversationMemoryManager`, `ContextDetector`, `VoiceInputManager`
- **UI Components**: `AIAssistantChatView`, `AIWorkspaceView`

### HIG (Human Interface Guidelines)
Located in `HIG/` directory (as a submodule), this package provides:
- **HIG Package**: Swift package for loading and working with Apple HIG documentation
- **Advanced UI Components**: `HIGChatView`, `DocuChatUI`, `AgentOrchestrationView`
- **Sophisticated Views**: `LiquidGlassWindow`, `AIKnowledgeSettingsView`, etc.
- **Data Models**: HIG documentation models and loaders

## View Organization

Views in the app are organized into two folders:

### `AIAssistantApp/Views/Kit/`
Contains views that primarily use AIAssistantKit components:
- **ChatTabView.swift**: Chat interface using `AIAssistantChatView` from AIAssistantKit
- **WorkspaceTabView.swift**: Workspace interface using `AIWorkspaceView` from AIAssistantKit

### `AIAssistantApp/Views/HIG/`
Contains views following HIG design patterns:
- **MasterView.swift**: Main navigation view with sidebar
- **SettingsTabView.swift**: Settings configuration view
- **AboutView.swift**: About dialog

## Using the Packages

### Importing Packages

```swift
import AIAssistantKit  // For AI functionality
import HIGPackage      // For HIG documentation and utilities
```

### Using AIAssistantKit Components

#### Implementing an AI Provider

```swift
import AIAssistantKit

@MainActor
final class CustomAIProvider: AIProvider, ObservableObject {
    @Published var suggestions: [AISuggestion] = []
    
    func ask(query: String, context: AIContext?) async throws -> AIResponse {
        // Your AI implementation
        return AIResponse(
            message: "Response",
            canGenerate: true,
            suggestedActions: []
        )
    }
    
    func askStreaming(query: String, context: AIContext?) -> AsyncThrowingStream<String, Error> {
        // Your streaming implementation
    }
}
```

#### Using AI Chat View

```swift
import SwiftUI
import AIAssistantKit

struct MyChatView: View {
    @StateObject var provider: AIProvider
    @State var isExpanded = true
    @State var height: CGFloat = 400
    
    var body: some View {
        AIAssistantChatView(
            provider: provider,
            isExpanded: $isExpanded,
            height: $height,
            conversationId: "my-conversation",
            configuration: .default
        )
    }
}
```

#### Using AI Workspace View

```swift
import SwiftUI
import AIAssistantKit

struct MyWorkspaceView: View {
    var body: some View {
        AIWorkspaceView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

### Using HIG Package

#### Loading HIG Documentation

```swift
import HIGPackage

// Load HIG documentation
if let url = Bundle.main.url(forResource: "hig_combined", withExtension: "json") {
    let document = try HIGDataLoader.load(from: url)
    let foundations = HIGDataLoader.topics(for: "Foundations", in: document)
    
    // Use the loaded HIG documentation
    for topic in foundations {
        print(topic.title)
    }
}
```

#### Integrating HIG Views

The HIG repository contains sophisticated SwiftUI views that can be integrated:

- **HIGChatView**: Advanced chat interface with HIG knowledge integration
- **DocuChatUI**: Documentation-aware chat interface
- **AgentOrchestrationView**: AI agent orchestration interface
- **LiquidGlassWindow**: Modern glass-effect window design
- **AIKnowledgeSettingsView**: Settings view for AI knowledge configuration

To use these views, you can either:
1. Import them directly from the HIG package if they're exported
2. Copy and adapt them into your app's HIG views folder
3. Reference them as examples for building HIG-compliant interfaces

## Services

### Conversation Memory Manager

```swift
import AIAssistantKit

let memoryManager = ConversationMemoryManager()

// Add messages
memoryManager.addMessage("Hello!", to: "conversation-1")

// Get conversation
let messages = memoryManager.getConversation("conversation-1")

// Clear conversation
memoryManager.clearConversation("conversation-1")
```

### Context Detector

```swift
import AIAssistantKit

let detector = ContextDetector()
if let context = detector.detectContext() {
    // Use detected context
}
```

### Voice Input Manager

```swift
import AIAssistantKit

let voiceManager = VoiceInputManager()
voiceManager.startListening()
// ... later
voiceManager.stopListening()
```

## Xcode Project Configuration

Both packages are added as local Swift package references in the Xcode project:

1. **AIAssistantKit**: `relativePath = AIAssistantKit`
2. **HIG**: `relativePath = HIG` (as a Git submodule)

The main app target includes both package products:
- `AIAssistantKit`
- `HIGPackage`

## Building the Project

### Prerequisites
- macOS 14.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

### Build Steps

1. Open `AIAssistantApp.xcodeproj` in Xcode
2. Select the `AIAssistantApp` scheme
3. Build and run (Cmd+R)

Alternatively, from the command line:
```bash
xcodebuild -project AIAssistantApp.xcodeproj -scheme AIAssistantApp -configuration Debug build
```

## Git Submodule Notes

HIG is added as a Git submodule. To clone the repository with submodules:

```bash
git clone --recursive https://github.com/littlesunshine0/AIAssistantApp
```

If you've already cloned without `--recursive`:

```bash
git submodule update --init --recursive
```

## Future Enhancements

Potential areas for expansion:

1. **Custom AI Providers**: Integrate OpenAI, Anthropic, or local LLM providers
2. **HIG View Adoption**: Migrate more app views to use HIG package components
3. **Enhanced Workspace**: Expand workspace functionality with HIG's advanced features
4. **Voice Integration**: Complete voice input/output implementation
5. **Context Detection**: Enhance context detection for better AI responses

## Contributing

When adding new features:

1. Place AIAssistantKit-focused views in `Views/Kit/`
2. Place HIG-compliant views in `Views/HIG/`
3. Extend AIAssistantKit package for new AI capabilities
4. Reference HIG package for design guidelines and components
5. Update this documentation as needed

## License

Copyright © 2025 AIAssistantKit. All rights reserved.
