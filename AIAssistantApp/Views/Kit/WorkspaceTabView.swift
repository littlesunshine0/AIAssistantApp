//
//  WorkspaceTabView.swift
//  AIAssistantApp
//
//  Workspace interface tab view
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import SwiftUI
import AIAssistantKit

/// Workspace tab view providing project management and AI workspace features.
struct WorkspaceTabView: View {
    @EnvironmentObject var controller: AppController
    @State private var showKnowledgeBase = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Enhanced header
            workspaceHeader
            
            Divider()
            
            // Use the enhanced workspace view with full features
            EnhancedWorkspaceView()
        }
        .navigationTitle("AI Workspace")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: { showKnowledgeBase = true }) {
                    Label("Knowledge Base", systemImage: "book.fill")
                }
            }
        }
        .sheet(isPresented: $showKnowledgeBase) {
            KnowledgeBaseView()
                .frame(width: 900, height: 700)
        }
    }
    
    private var workspaceHeader: some View {
        HStack {
            Image(systemName: "square.grid.2x2")
                .foregroundColor(.blue)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Enhanced Workspace")
                    .font(.headline)
                
                Text("Projects, tasks, and offline knowledge management")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                FeatureBadge(icon: "folder.fill", color: .blue, text: "Projects")
                FeatureBadge(icon: "checkmark.circle", color: .green, text: "Tasks")
                FeatureBadge(icon: "book.fill", color: .purple, text: "Knowledge")
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}

// MARK: - Preview

#if DEBUG
struct WorkspaceTabView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceTabView()
            .environmentObject(AppController.shared)
    }
}
#endif
