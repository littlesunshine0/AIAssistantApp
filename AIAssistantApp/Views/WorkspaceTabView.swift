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
    
    var body: some View {
        VStack(spacing: 0) {
            // Use the existing AIWorkspaceView from the kit
            AIWorkspaceView()
        }
        .navigationTitle("AI Workspace")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("New Project", action: {})
                    Button("Open Project", action: {})
                    Divider()
                    Button("Export Workspace", action: {})
                } label: {
                    Label("Actions", systemImage: "ellipsis.circle")
                }
            }
        }
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
