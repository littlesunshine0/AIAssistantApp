//
//  MasterView.swift
//  AIAssistantApp
//
//  Master view coordinating all application features
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import SwiftUI
import AIAssistantKit

/// Master view providing the main navigation and content area.
///
/// `MasterView` serves as the primary interface for the AI Assistant application,
/// providing tabbed navigation to all major features.
struct MasterView: View {
    @EnvironmentObject var controller: AppController
    
    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            contentArea
        }
        .navigationTitle("AI Assistant")
        .sheet(isPresented: $controller.showAbout) {
            AboutView()
        }
    }
    
    // MARK: - Sidebar
    
    private var sidebar: some View {
        List(MasterTab.allCases, selection: $controller.selectedTab) { tab in
            NavigationLink(value: tab) {
                Label(tab.rawValue, systemImage: tab.icon)
            }
        }
        .navigationTitle("Navigation")
        .frame(minWidth: 200)
    }
    
    // MARK: - Content Area
    
    @ViewBuilder
    private var contentArea: some View {
        switch controller.selectedTab {
        case .chat:
            ChatTabView()
        case .workspace:
            WorkspaceTabView()
        case .settings:
            SettingsTabView()
        case .about:
            AboutView()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct MasterView_Previews: PreviewProvider {
    static var previews: some View {
        MasterView()
            .environmentObject(AppController.shared)
    }
}
#endif
