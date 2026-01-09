//
//  KnowledgeBaseView.swift
//  AIAssistantKit
//
//  Offline knowledge base browser and manager
//  Copyright © 2025 AIAssistantKit. All rights reserved.
//

import SwiftUI

/// Knowledge base browser view for offline AI context
public struct KnowledgeBaseView: View {
    @StateObject private var viewModel = KnowledgeBaseViewModel()
    @State private var showingAddEntry = false
    @State private var selectedEntry: KnowledgeEntry?
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            if let entry = selectedEntry {
                entryDetailView(entry)
            } else {
                emptyStateView
            }
        }
        .navigationTitle("Knowledge Base")
        .searchable(text: $viewModel.searchQuery, prompt: "Search knowledge...")
        .onChange(of: viewModel.searchQuery) { _ in
            viewModel.loadEntries()
        }
        .sheet(isPresented: $showingAddEntry) {
            AddKnowledgeEntryView { entry in
                viewModel.addEntry(entry)
                showingAddEntry = false
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddEntry = true }) {
                    Label("Add Entry", systemImage: "plus")
                }
            }
        }
    }
    
    private var sidebar: some View {
        VStack(spacing: 0) {
            // Category filter
            Picker("Category", selection: $viewModel.selectedCategory) {
                Text("All").tag(nil as KnowledgeCategory?)
                ForEach(KnowledgeCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category as KnowledgeCategory?)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: viewModel.selectedCategory) { _ in
                viewModel.loadEntries()
            }
            
            Divider()
            
            // Entry list
            List(viewModel.entries, selection: $selectedEntry) { entry in
                NavigationLink(value: entry) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.title)
                            .font(.headline)
                        
                        Text(entry.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if !entry.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 4) {
                                    ForEach(entry.tags, id: \.self) { tag in
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
                        
                        HStack {
                            Text("Accessed \(entry.accessCount) times")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(entry.lastAccessed.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .contextMenu {
                    Button(role: .destructive) {
                        viewModel.deleteEntry(entry.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .listStyle(.sidebar)
        }
        .frame(minWidth: 250)
        .onChange(of: selectedEntry) { entry in
            if let entry = entry {
                viewModel.incrementAccess(entry.id)
            }
        }
    }
    
    private func entryDetailView(_ entry: KnowledgeEntry) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Label(entry.category.rawValue, systemImage: "folder.fill")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Created \(entry.createdAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !entry.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(entry.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    if let source = entry.source {
                        Text("Source: \(source)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                .padding()
                .background(Color(.controlBackgroundColor).opacity(0.5))
                .cornerRadius(12)
                
                Divider()
                
                // Content
                Text(entry.content)
                    .font(.body)
                    .textSelection(.enabled)
                    .padding()
                
                // Stats
                HStack {
                    Label("\(entry.accessCount) accesses", systemImage: "eye")
                    
                    Spacer()
                    
                    Label("Last: \(entry.lastAccessed.formatted(date: .abbreviated, time: .shortened))", systemImage: "clock")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(Color(.controlBackgroundColor).opacity(0.3))
                .cornerRadius(8)
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Select an entry to view")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("or add new knowledge to your offline library")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("Add Knowledge Entry") {
                showingAddEntry = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Add Knowledge Entry View

struct AddKnowledgeEntryView: View {
    let onSave: (KnowledgeEntry) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @State private var category: KnowledgeCategory = .general
    @State private var tags = ""
    @State private var source = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    
                    Picker("Category", selection: $category) {
                        ForEach(KnowledgeCategory.allCases, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    
                    TextField("Tags (comma separated)", text: $tags)
                    
                    TextField("Source (optional)", text: $source)
                }
                
                Section("Content") {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                        .font(.body)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Add Knowledge Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let tagArray = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        let entry = KnowledgeEntry(
                            title: title,
                            content: content,
                            category: category,
                            tags: tagArray,
                            source: source.isEmpty ? nil : source
                        )
                        onSave(entry)
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
        .frame(width: 600, height: 500)
    }
}
