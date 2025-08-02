//
//  ContentView.swift
//  stack
//
//  Created by Kabir Teria on 02/08/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var ideaStore: IdeaStore
    @State private var newIdeaText = ""
    @State private var showCategoryDropdown = false
    @State private var selectedCategoryIndex = 0
    @State private var placeholderIndex = 0
    @State private var shakeAnimation = false
    @State private var isDarkMode = true
    @FocusState private var isInputFocused: Bool
    
    private let placeholders = [
        "capture an idea...",
        "what's on your mind?", 
        "jot something down...",
        "quick thought?",
        "brain dump here..."
    ]
    
    private var currentPlaceholder: String {
        placeholders[placeholderIndex % placeholders.count]
    }
    
    private var filteredCategories: [Category] {
        if newIdeaText.contains(":") {
            let components = newIdeaText.components(separatedBy: ":")
            if let lastComponent = components.last?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
                if lastComponent.isEmpty {
                    return ideaStore.getAllCategories()
                }
                return ideaStore.getAllCategories().filter { 
                    $0.name.lowercased().hasPrefix(lastComponent)
                }
            }
        }
        return ideaStore.getAllCategories()
    }
    
    private var totalIdeasCount: Int {
        ideaStore.ideas.count
    }
    
    private var backgroundColor: Color {
        isDarkMode ? Color.black : Color.white
    }
    
    private var textColor: Color {
        isDarkMode ? .white : .black
    }
    
    var body: some View {
        GeometryReader { geometry in
            mainContentView(geometry: geometry)
        }
        .background(backgroundColor)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onTapGesture {
            showCategoryDropdown = false
        }
        .onAppear {
            isInputFocused = true
            startPlaceholderTimer()
        }
    }
    
    private func addNewIdea() {
        let trimmedText = newIdeaText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty {
            let (cleanText, category) = Category.parse(from: trimmedText)
            let newIdea = Idea(text: cleanText, category: category)
            ideaStore.addIdea(newIdea)
            newIdeaText = ""
            showCategoryDropdown = false
            cyclePlaceholder()
        } else {
            // Shake animation for empty input
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                shakeAnimation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                shakeAnimation = false
            }
        }
    }
    
    private func selectCategory(_ category: Category) {
        let components = newIdeaText.components(separatedBy: ":")
        if components.count >= 2 {
            let textPart = components.dropLast().joined(separator: ":")
            newIdeaText = "\(textPart):\(category.name)"
        }
        showCategoryDropdown = false
        selectedCategoryIndex = 0
        isInputFocused = true
    }
    
    private func startPlaceholderTimer() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            cyclePlaceholder()
        }
    }
    
    private func cyclePlaceholder() {
        withAnimation(.easeInOut(duration: 0.3)) {
            placeholderIndex += 1
        }
    }
    
    // MARK: - View Components
    
    private func mainContentView(geometry: GeometryProxy) -> some View {
        HStack {
            Spacer()
            
            VStack(spacing: 0) {
                inputSection
                contentSection
                Spacer()
            }
            .frame(width: geometry.size.width * 0.75)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
    }
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            inputField
            categoryDropdown
        }
    }
    
    private var inputField: some View {
        ZStack(alignment: .leading) {
            if newIdeaText.isEmpty {
                Text(currentPlaceholder)
                    .foregroundColor(Color.gray.opacity(0.4))
                    .font(.system(size: 18, weight: .regular, design: .default))
                    .animation(.easeInOut(duration: 0.3), value: currentPlaceholder)
            }
            
            TextField("", text: $newIdeaText)
                .textFieldStyle(PlainTextFieldStyle())
                .focused($isInputFocused)
                .foregroundColor(textColor)
                .font(.system(size: 18, weight: .regular, design: .default))
                .lineSpacing(4)
                .onChange(of: newIdeaText) { newValue in
                    let wasShowingDropdown = showCategoryDropdown
                    showCategoryDropdown = newValue.contains(":")
                    
                    if showCategoryDropdown && !wasShowingDropdown {
                        selectedCategoryIndex = 0
                    }
                }
                .onSubmit {
                    if showCategoryDropdown && !filteredCategories.isEmpty && selectedCategoryIndex < filteredCategories.count {
                        selectCategory(filteredCategories[selectedCategoryIndex])
                        addNewIdea()
                    } else {
                        addNewIdea()
                    }
                }
        }
        .padding(.horizontal, 40)
        .padding(.top, 40)
        .padding(.bottom, 16)
        .offset(x: shakeAnimation ? -8 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: shakeAnimation)
    }
    
    @ViewBuilder
    private var categoryDropdown: some View {
        if showCategoryDropdown && !filteredCategories.isEmpty {
            VStack(alignment: .leading, spacing: 1) {
                ForEach(Array(filteredCategories.enumerated()), id: \.element.name) { index, category in
                    categoryItem(category: category, index: index)
                }
            }
            .padding(.bottom, 16)
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
    
    private func categoryItem(category: Category, index: Int) -> some View {
        HStack {
            Text(":")
                .foregroundColor(Color.gray.opacity(0.5))
                .font(.system(size: 16, weight: .regular, design: .default))
            
            Text(category.name)
                .foregroundColor(categoryTextColor(for: index))
                .font(.system(size: 16, weight: .regular, design: .default))
            Spacer()
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 4)
        .background(categoryBackgroundColor(for: index))
        .cornerRadius(4)
        .animation(.easeInOut(duration: 0.2), value: selectedCategoryIndex)
    }
    
    private func categoryTextColor(for index: Int) -> Color {
        if index == selectedCategoryIndex {
            return textColor
        } else {
            return Color.gray.opacity(0.7)
        }
    }
    
    private func categoryBackgroundColor(for index: Int) -> Color {
        if index == selectedCategoryIndex {
            let highlightColor = isDarkMode ? Color.white : Color.black
            return highlightColor.opacity(0.08)
        } else {
            return Color.clear
        }
    }
    
    private var contentSection: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                if ideaStore.ideas.isEmpty {
                    HStack {
                        Spacer()
                        EmptyStateView()
                        Spacer()
                    }
                    .padding(.top, 60)
                } else {
                    ForEach(ideaStore.ideasGroupedByDay(), id: \.0) { day, ideas in
                        daySection(day: day, ideas: ideas)
                    }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: ideaStore.ideas.count)
        }
    }
    
    private func daySection(day: String, ideas: [Idea]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(day)
                .font(.system(size: 13, weight: .medium, design: .default))
                .foregroundColor(Color.gray.opacity(0.6))
                .padding(.horizontal, 40)
            
            ForEach(ideas) { idea in
                IdeaRowView(idea: idea, ideaStore: ideaStore, isDarkMode: isDarkMode)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
            }
        }
    }
    
    private var bottomBar: some View {
        HStack {
            Spacer()
            
            HStack(spacing: 16) {
                if totalIdeasCount > 0 {
                    Text("\(totalIdeasCount) idea\(totalIdeasCount == 1 ? "" : "s")")
                        .font(.system(size: 11, weight: .medium, design: .default))
                        .foregroundColor(Color.gray.opacity(0.4))
                }
                
                Button(action: {
                    isDarkMode.toggle()
                }) {
                    Image(systemName: isDarkMode ? "sun.max" : "moon")
                        .font(.system(size: 12))
                        .foregroundColor(Color.gray.opacity(0.5))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
        .background(backgroundColor)
    }
}

struct IdeaRowView: View {
    let idea: Idea
    let ideaStore: IdeaStore
    let isDarkMode: Bool
    @State private var isHovered = false
    
    private var timeAgo: String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(idea.timestamp)
        
        if timeInterval < 60 {
            return "just now"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m ago"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days)d ago"
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Delete icon (visible on hover) - before the text
            if isHovered {
                Button(action: {
                    ideaStore.deleteIdea(idea)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(Color(red: 1.0, green: 0.23, blue: 0.19)) // Apple red #FF3B30
                        .font(.system(size: 12))
                }
                .buttonStyle(PlainButtonStyle())
                .transition(.scale.combined(with: .opacity))
            }
            
            // Main text content
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 8) {
                        Text(idea.text)
                            .font(.system(size: 17, weight: .regular, design: .default))
                            .foregroundColor(isDarkMode ? .white : .black)
                            .lineSpacing(4)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            // Timestamp inline on hover
                            if isHovered {
                                Text(timeAgo)
                                    .font(.system(size: 11, weight: .regular, design: .default))
                                    .foregroundColor(Color.gray.opacity(0.4))
                                    .transition(.opacity)
                            }
                            
                            // Category as subtle text
                            Text(idea.category.name)
                                .font(.system(size: 12, weight: .medium, design: .default))
                                .foregroundColor(Color.gray.opacity(0.5))
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 4)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

struct EmptyStateView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lightbulb")
                .font(.system(size: 32, weight: .ultraLight))
                .foregroundColor(.gray.opacity(0.3))
            
            VStack(spacing: 8) {
                Text("no ideas yet")
                    .font(.system(size: 18, weight: .regular, design: .default))
                    .foregroundColor(.gray.opacity(0.5))
                
                Text("start typing to capture your first thought")
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(.gray.opacity(0.3))
                
                Text("use :work, :personal, or :random to categorize")
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundColor(.gray.opacity(0.25))
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    ContentView()
}
