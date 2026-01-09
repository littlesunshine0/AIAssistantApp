//
//  UIUtilities.swift
//  AIAssistantKit
//
//  UI utilities for rendering and formatting
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import SwiftUI

// MARK: - Markdown Renderer

/// Simple markdown renderer for chat messages
public struct MarkdownRenderer {
    public init() {}
    
    public func render(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
        
        // Bold text **text**
        attributed = applyPattern(to: attributed, pattern: "\\*\\*(.*?)\\*\\*") { match in
            var container = AttributeContainer()
            container.font = .body.bold()
            return container
        }
        
        // Italic text *text*
        attributed = applyPattern(to: attributed, pattern: "\\*(.*?)\\*") { match in
            var container = AttributeContainer()
            container.font = .body.italic()
            return container
        }
        
        // Inline code `code`
        attributed = applyPattern(to: attributed, pattern: "`(.*?)`") { match in
            var container = AttributeContainer()
            container.font = .monospaced(.body)()
            container.backgroundColor = .secondary.opacity(0.1)
            return container
        }
        
        return attributed
    }
    
    private func applyPattern(
        to attributed: AttributedString,
        pattern: String,
        attributes: (String) -> AttributeContainer
    ) -> AttributedString {
        var result = attributed
        let text = String(attributed.characters)
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: text) {
                    let matchText = String(text[range])
                    if let attrRange = Range(match.range, in: text),
                       let startIndex = AttributedString.Index(attrRange.lowerBound, within: result),
                       let endIndex = AttributedString.Index(attrRange.upperBound, within: result) {
                        result[startIndex..<endIndex].setAttributes(attributes(matchText))
                    }
                }
            }
        }
        
        return result
    }
}

// MARK: - Syntax Highlighter

/// Syntax highlighter for code blocks
public struct SyntaxHighlighter {
    public init() {}
    
    public func highlight(code: String, language: String) -> AttributedString {
        var attributed = AttributedString(code)
        
        switch language.lowercased() {
        case "swift":
            attributed = highlightSwift(attributed)
        case "python":
            attributed = highlightPython(attributed)
        case "javascript", "js":
            attributed = highlightJavaScript(attributed)
        default:
            break
        }
        
        return attributed
    }
    
    private func highlightSwift(_ text: AttributedString) -> AttributedString {
        var result = text
        let keywords = [
            "func", "var", "let", "class", "struct", "enum", "protocol",
            "if", "else", "switch", "case", "for", "while", "return",
            "import", "public", "private", "internal", "static", "mutating"
        ]
        
        for keyword in keywords {
            result = highlightWord(result, word: keyword, color: .purple)
        }
        
        return result
    }
    
    private func highlightPython(_ text: AttributedString) -> AttributedString {
        var result = text
        let keywords = [
            "def", "class", "if", "else", "elif", "for", "while",
            "return", "import", "from", "as", "try", "except", "with"
        ]
        
        for keyword in keywords {
            result = highlightWord(result, word: keyword, color: .purple)
        }
        
        return result
    }
    
    private func highlightJavaScript(_ text: AttributedString) -> AttributedString {
        var result = text
        let keywords = [
            "function", "var", "let", "const", "class", "if", "else",
            "for", "while", "return", "import", "export", "async", "await"
        ]
        
        for keyword in keywords {
            result = highlightWord(result, word: keyword, color: .purple)
        }
        
        return result
    }
    
    private func highlightWord(_ text: AttributedString, word: String, color: Color) -> AttributedString {
        var result = text
        let pattern = "\\b\(word)\\b"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let str = String(text.characters)
            let matches = regex.matches(in: str, range: NSRange(str.startIndex..., in: str))
            
            for match in matches {
                if let range = Range(match.range, in: str),
                   let startIndex = AttributedString.Index(range.lowerBound, within: result),
                   let endIndex = AttributedString.Index(range.upperBound, within: result) {
                    result[startIndex..<endIndex].foregroundColor = color
                }
            }
        }
        
        return result
    }
}

// MARK: - Code Block View

/// View for displaying code blocks with syntax highlighting
public struct CodeBlockView: View {
    let codeBlock: CodeBlock
    @State private var copied = false
    
    private let highlighter = SyntaxHighlighter()
    
    public init(codeBlock: CodeBlock) {
        self.codeBlock = codeBlock
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text(codeBlock.language.uppercased())
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: copyCode) {
                    Label(copied ? "Copied!" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.secondary.opacity(0.1))
            
            Divider()
            
            // Code
            ScrollView([.horizontal, .vertical]) {
                Text(highlighter.highlight(code: codeBlock.code, language: codeBlock.language))
                    .font(.system(.body, design: .monospaced))
                    .padding(12)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.controlBackgroundColor).opacity(0.5))
        }
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func copyCode() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(codeBlock.code, forType: .string)
        copied = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copied = false
        }
    }
}

// MARK: - Enhanced Message View

/// Enhanced message bubble with markdown and code support
public struct EnhancedMessageBubble: View {
    let message: Message
    let onToggleFavorite: () -> Void
    let onDelete: () -> Void
    
    private let renderer = MarkdownRenderer()
    
    public init(
        message: Message,
        onToggleFavorite: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.message = message
        self.onToggleFavorite = onToggleFavorite
        self.onDelete = onDelete
    }
    
    public var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
            HStack {
                if message.isUser { Spacer() }
                
                VStack(alignment: .leading, spacing: 12) {
                    // Message text with markdown
                    Text(renderer.render(message.content))
                        .textSelection(.enabled)
                    
                    // Code blocks
                    if !message.codeBlocks.isEmpty {
                        ForEach(message.codeBlocks) { codeBlock in
                            CodeBlockView(codeBlock: codeBlock)
                        }
                    }
                    
                    // Timestamp and actions
                    HStack(spacing: 8) {
                        Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        if message.metadata.edited {
                            Text("(edited)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                        
                        Spacer()
                        
                        Button(action: onToggleFavorite) {
                            Image(systemName: message.isFavorite ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(message.isFavorite ? .yellow : .secondary)
                        }
                        .buttonStyle(.borderless)
                        
                        if message.isUser {
                            Button(action: onDelete) {
                                Image(systemName: "trash")
                                    .font(.caption)
                                    .foregroundColor(.red.opacity(0.7))
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
                .padding(12)
                .background(message.isUser ? Color.blue : Color(.controlBackgroundColor))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(12)
                .frame(maxWidth: .infinity * 0.75, alignment: message.isUser ? .trailing : .leading)
                
                if !message.isUser { Spacer() }
            }
        }
    }
}
