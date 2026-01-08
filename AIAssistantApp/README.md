# AIAssistantApp - GUI Executable

This directory contains the GUI executable application that provides a comprehensive interface for AIAssistantKit.

## Overview

AIAssistantApp is a native macOS application that integrates all the features of AIAssistantKit into a user-friendly GUI with master views and controllers.

## Features

- **Master View Architecture**: Tabbed interface for navigating all features
- **AppController**: Central coordinator managing app state and services
- **Chat Interface**: Full-featured AI chat with streaming responses
- **Workspace**: Project management and AI workspace features
- **Settings**: Configuration for AI providers, features, and performance
- **About**: Application information and feature overview

## Architecture

### Controllers

- **AppController**: Master controller coordinating application state
  - Manages navigation between tabs
  - Coordinates AI provider and services
  - Handles global app state

- **DefaultAIProvider**: Default AI provider implementation
  - Demonstrates AI integration patterns
  - Provides sample responses
  - Can be replaced with production AI backend

### Views

- **MasterView**: Main navigation container with sidebar
- **ChatTabView**: AI chat interface tab
- **WorkspaceTabView**: Project workspace tab
- **SettingsTabView**: Application settings
- **AboutView**: About dialog with feature list

## Building

### Requirements

- macOS 14.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

### Build from Command Line

```bash
# Build the executable
swift build -c release

# Run the executable
.build/release/AIAssistantApp
```

### Build with Xcode

```bash
# Generate Xcode project
swift package generate-xcodeproj

# Or open with Xcode directly
open Package.swift
```

Then select the `AIAssistantApp` scheme and build/run.

## Usage

1. Launch the application
2. Use the sidebar to navigate between:
   - **Chat**: Interact with the AI assistant
   - **Workspace**: Manage projects and tasks
   - **Settings**: Configure AI provider and preferences
   - **About**: View application information

### Chat Tab

- Type your questions or requests in the input field
- View AI responses with syntax-highlighted code
- Create new conversations
- Clear conversation history

### Workspace Tab

- Access the full AIWorkspaceView
- Manage project requirements
- View design documents
- Track tasks on the board

### Settings Tab

- Configure AI provider API keys
- Select AI model (GPT-4, GPT-3.5, Claude, Local)
- Enable/disable features (voice input, streaming)
- Adjust performance settings (max tokens)
- Manage conversations

## Customization

### Adding a Custom AI Provider

Replace `DefaultAIProvider` in `AppController.swift`:

```swift
@Published var aiProvider: YourCustomProvider
```

Implement the `AIProvider` protocol with your backend:

```swift
@MainActor
final class YourCustomProvider: AIProvider, ObservableObject {
    // Implement required methods
    func ask(query: String, context: AIContext?) async throws -> AIResponse {
        // Your implementation
    }
    
    func askStreaming(query: String, context: AIContext?) -> AsyncThrowingStream<String, Error> {
        // Your implementation
    }
}
```

### Adding New Tabs

1. Add a new case to `MasterTab` enum in `AppController.swift`
2. Create a new view file in `Views/`
3. Add the view to the switch statement in `MasterView.swift`

## Distribution

### Create a macOS App Bundle

```bash
# Build for release
swift build -c release

# Create app bundle structure
mkdir -p AIAssistant.app/Contents/MacOS
mkdir -p AIAssistant.app/Contents/Resources

# Copy executable
cp .build/release/AIAssistantApp AIAssistant.app/Contents/MacOS/

# Create Info.plist
# (See below for template)
```

### Info.plist Template

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>AIAssistantApp</string>
    <key>CFBundleIdentifier</key>
    <string>com.aiassistantkit.app</string>
    <key>CFBundleName</key>
    <string>AI Assistant</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
</dict>
</plist>
```

## License

Copyright © 2025 AIAssistantKit. All rights reserved.
