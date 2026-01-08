//
//  AboutView.swift
//  AIAssistantApp
//
//  About dialog view
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import SwiftUI
import AIAssistantKit

/// About view displaying application information.
struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // App Icon
            Image(systemName: "sparkles.rectangle.stack.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.top, 30)
            
            // App Name
            Text("AI Assistant")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Version
            Text("Version \(AIAssistantKit.version)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.horizontal, 40)
            
            // Description
            VStack(alignment: .leading, spacing: 12) {
                Text("Features:")
                    .font(.headline)
                
                FeatureRow(icon: "message.fill", text: "AI-powered chat interface")
                FeatureRow(icon: "wand.and.stars", text: "Code generation and refactoring")
                FeatureRow(icon: "square.grid.2x2", text: "Comprehensive workspace management")
                FeatureRow(icon: "brain.head.profile", text: "Context-aware suggestions")
                FeatureRow(icon: "mic.fill", text: "Voice input support")
                FeatureRow(icon: "doc.text", text: "Markdown and code rendering")
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Copyright
            Text("Copyright © 2025 AIAssistantKit. All rights reserved.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
            
            // Close button
            Button("Close") {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
            .padding(.bottom, 20)
        }
        .frame(width: 500, height: 600)
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
#endif
