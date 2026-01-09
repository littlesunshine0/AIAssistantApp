//
//  EnhancedWorkspaceView.swift
//  AIAssistantKit
//
//  Enhanced workspace with project and task management
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import SwiftUI

/// Enhanced workspace view with full project management
public struct EnhancedWorkspaceView: View {
    @StateObject private var viewModel = WorkspaceViewModel()
    @State private var selectedTab: WorkspaceTab = .projects
    @State private var showingAddProject = false
    @State private var showingAddTask = false
    
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
                projectsView
            case .tasks:
                tasksView
            case .documents:
                documentsView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showingAddProject) {
            AddProjectView { project in
                viewModel.addProject(project)
                showingAddProject = false
            }
        }
    }
    
    private var projectsView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Projects")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { showingAddProject = true }) {
                    Label("New Project", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(.controlBackgroundColor).opacity(0.5))
            
            if viewModel.projects.isEmpty {
                emptyProjectsView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.projects) { project in
                            ProjectCard(
                                project: project,
                                onUpdate: { viewModel.updateProject($0) },
                                onDelete: { viewModel.deleteProject(project.id) },
                                onAddTask: { task in
                                    viewModel.addTaskToProject(task, projectId: project.id)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private var tasksView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("All Tasks")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(allTasksCount) total")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.controlBackgroundColor).opacity(0.5))
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.projects) { project in
                        if !project.tasks.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(project.name)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                ForEach(project.tasks) { task in
                                    TaskRow(
                                        task: task,
                                        onToggle: {
                                            viewModel.toggleTaskCompletion(task.id, projectId: project.id)
                                        }
                                    )
                                }
                            }
                            .padding()
                            .background(Color(.controlBackgroundColor).opacity(0.3))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private var documentsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.richtext")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Documents")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("AI-generated documentation and notes will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Generate Documentation") {
                // TODO: Implement documentation generation
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var emptyProjectsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Projects Yet")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Create your first AI-assisted project")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("Create Project") {
                showingAddProject = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var allTasksCount: Int {
        viewModel.projects.reduce(0) { $0 + $1.tasks.count }
    }
}

// MARK: - Project Card

struct ProjectCard: View {
    let project: Project
    let onUpdate: (Project) -> Void
    let onDelete: () -> Void
    let onAddTask: (Task) -> Void
    
    @State private var isExpanded = false
    @State private var showingAddTask = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.headline)
                    
                    Text(project.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Status badge
                Text(project.status.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
            }
            
            // Stats
            HStack(spacing: 16) {
                Label("\(project.tasks.count) tasks", systemImage: "checkmark.circle")
                
                let completed = project.tasks.filter { $0.completed }.count
                if completed > 0 {
                    Label("\(completed) done", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .buttonStyle(.borderless)
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            // Expanded content
            if isExpanded {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    if !project.tasks.isEmpty {
                        ForEach(project.tasks) { task in
                            TaskRow(task: task) {
                                // Toggle handled by parent
                            }
                        }
                    } else {
                        Text("No tasks yet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    
                    Button(action: { showingAddTask = true }) {
                        Label("Add Task", systemImage: "plus")
                            .font(.caption)
                    }
                    .buttonStyle(.borderless)
                }
            }
            
            // Footer
            HStack {
                if !project.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(project.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Menu {
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
        .sheet(isPresented: $showingAddTask) {
            AddTaskView { task in
                onAddTask(task)
                showingAddTask = false
            }
        }
    }
    
    private var statusColor: Color {
        switch project.status {
        case .active: return .green
        case .paused: return .orange
        case .completed: return .blue
        case .archived: return .gray
        }
    }
}

// MARK: - Task Row

struct TaskRow: View {
    let task: Task
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.completed ? .green : .secondary)
            }
            .buttonStyle(.borderless)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.completed)
                    .foregroundColor(task.completed ? .secondary : .primary)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Priority badge
            Circle()
                .fill(priorityColor)
                .frame(width: 8, height: 8)
            
            if task.aiGenerated {
                Image(systemName: "sparkles")
                    .font(.caption2)
                    .foregroundColor(.purple)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case .low: return .gray
        case .medium: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
}

// MARK: - Add Project View

struct AddProjectView: View {
    let onSave: (Project) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var tags = ""
    @State private var status: ProjectStatus = .active
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Project Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...5)
                }
                
                Section("Configuration") {
                    Picker("Status", selection: $status) {
                        ForEach(ProjectStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    
                    TextField("Tags (comma separated)", text: $tags)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let tagArray = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        let project = Project(
                            name: name,
                            description: description,
                            tags: tagArray,
                            status: status
                        )
                        onSave(project)
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        .frame(width: 500, height: 400)
    }
}

// MARK: - Add Task View

struct AddTaskView: View {
    let onSave: (Task) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: TaskPriority = .medium
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Task Title", text: $title)
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(3...5)
                
                Picker("Priority", selection: $priority) {
                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                        Text(priority.rawValue).tag(priority)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let task = Task(
                            title: title,
                            description: description,
                            priority: priority
                        )
                        onSave(task)
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .frame(width: 400, height: 300)
    }
}
