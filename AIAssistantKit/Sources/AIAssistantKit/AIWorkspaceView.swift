//
//  AIWorkspaceView.swift
//  AIAssistantKit
//
//  AI Workspace interface view
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import SwiftUI

/// AI Workspace view component for project management
public struct AIWorkspaceView: View {
    @State private var selectedTab: WorkspaceTab = .projects
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Tabs
            Picker("Workspace", selection: $selectedTab) {
                ForEach(WorkspaceTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            Divider()
            
            // Content
            switch selectedTab {
            case .projects:
                ProjectsView()
            case .tasks:
                TasksView()
            case .documents:
                DocumentsView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

enum WorkspaceTab: String, CaseIterable, Identifiable {
    case projects = "Projects"
    case tasks = "Tasks"
    case documents = "Documents"
    
    var id: String { rawValue }
}

struct ProjectsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Projects")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Text("Manage your AI-assisted projects here")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // Placeholder content
                VStack(spacing: 12) {
                    ForEach(0..<3) { index in
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text("Project \(index + 1)")
                                    .font(.headline)
                                Text("Description goes here")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

struct TasksView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Tasks")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Text("Track your AI-generated tasks")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // Placeholder content
                VStack(spacing: 12) {
                    ForEach(0..<5) { index in
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.green)
                            
                            Text("Task \(index + 1)")
                                .font(.body)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

struct DocumentsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Documents")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Text("AI-generated documentation and notes")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // Placeholder content
                VStack(spacing: 12) {
                    ForEach(0..<4) { index in
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.purple)
                            
                            VStack(alignment: .leading) {
                                Text("Document \(index + 1)")
                                    .font(.headline)
                                Text("Notes and documentation")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}
