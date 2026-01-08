//
//  DefaultAIProvider.swift
//  AIAssistantApp
//
//  Default AI provider implementation for the app
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import SwiftUI
import AIAssistantKit
import Combine

/// Default implementation of AIProvider for the application.
///
/// This provider demonstrates basic AI functionality and can be replaced
/// with a production AI backend implementation.
@MainActor
final class DefaultAIProvider: AIProvider, ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var suggestions: [AISuggestion] = [
        AISuggestion(title: "Generate code", icon: "wand.and.stars"),
        AISuggestion(title: "Explain this", icon: "questionmark.circle"),
        AISuggestion(title: "Refactor code", icon: "arrow.triangle.2.circlepath"),
        AISuggestion(title: "Write tests", icon: "checkmark.circle"),
        AISuggestion(title: "Find bugs", icon: "ant.circle"),
        AISuggestion(title: "Optimize performance", icon: "speedometer")
    ]
    
    @Published var showAIPanel: Bool = false
    
    // MARK: - AI Provider Methods
    
    func ask(query: String, context: AIContext?) async throws -> AIResponse {
        // Simulate AI processing delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let contextInfo = buildContextString(context)
        let response = generateResponse(for: query, with: contextInfo)
        
        return AIResponse(
            message: response,
            canGenerate: query.lowercased().contains("generate") || query.lowercased().contains("create"),
            suggestedActions: []
        )
    }
    
    func askStreaming(query: String, context: AIContext?) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                let contextInfo = buildContextString(context)
                let response = generateResponse(for: query, with: contextInfo)
                
                // Stream the response word by word
                let words = response.split(separator: " ")
                for word in words {
                    try? await Task.sleep(nanoseconds: 50_000_000) // 50ms delay
                    continuation.yield(String(word) + " ")
                }
                continuation.finish()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func buildContextString(_ context: AIContext?) -> String {
        guard let context = context else { return "" }
        
        var parts: [String] = []
        
        if let file = context.currentFile {
            parts.append("File: \(file.path)")
            parts.append("Language: \(file.language)")
        }
        
        if let selected = context.selectedText {
            parts.append("Selected: \(selected)")
        }
        
        if let project = context.projectContext {
            parts.append("Project: \(project.name)")
            parts.append("Type: \(project.type)")
        }
        
        return parts.isEmpty ? "" : "\n\nContext:\n" + parts.joined(separator: "\n")
    }
    
    private func generateResponse(for query: String, with context: String) -> String {
        let lowercaseQuery = query.lowercased()
        
        if lowercaseQuery.contains("generate") || lowercaseQuery.contains("create") {
            return """
            I can help you generate code. Here's a sample structure:
            
            ```swift
            struct Example {
                let property: String
                
                func doSomething() {
                    print("Hello from generated code!")
                }
            }
            ```
            
            Would you like me to customize this based on your requirements?
            \(context)
            """
        } else if lowercaseQuery.contains("explain") {
            return """
            Let me explain the concept you're asking about.
            
            This appears to be related to Swift development. The key points are:
            
            1. **Structure**: Defines the data model
            2. **Properties**: Store the state
            3. **Methods**: Implement behavior
            
            Is there a specific aspect you'd like me to elaborate on?
            \(context)
            """
        } else if lowercaseQuery.contains("refactor") {
            return """
            For refactoring, I recommend:
            
            1. Extract common functionality into reusable components
            2. Apply SOLID principles
            3. Improve naming for clarity
            4. Reduce coupling between modules
            
            Would you like me to suggest specific refactorings?
            \(context)
            """
        } else if lowercaseQuery.contains("test") {
            return """
            Here's a test structure you can use:
            
            ```swift
            import XCTest
            
            final class ExampleTests: XCTestCase {
                func testExample() throws {
                    // Arrange
                    let sut = Example(property: "test")
                    
                    // Act
                    sut.doSomething()
                    
                    // Assert
                    XCTAssertNotNil(sut)
                }
            }
            ```
            \(context)
            """
        } else {
            return """
            I'm here to help! I can assist you with:
            
            - **Code generation**: Create new code structures
            - **Explanation**: Understand complex code
            - **Refactoring**: Improve code quality
            - **Testing**: Write comprehensive tests
            - **Debugging**: Find and fix issues
            
            What would you like me to help with?
            \(context)
            """
        }
    }
}
