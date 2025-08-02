//
//  IdeaStore.swift
//  stack
//
//  Created by Kabir Teria on 02/08/25.
//

import Foundation

class IdeaStore: ObservableObject {
    static let shared = IdeaStore()
    
    @Published var ideas: [Idea] = []
    
    private let userDefaults = UserDefaults.standard
    private let ideasKey = "stack_ideas"
    
    init() {
        loadIdeas()
        addSampleData()
    }
    
    func addIdea(_ idea: Idea) {
        ideas.append(idea)
        saveIdeas()
    }
    
    func deleteIdea(_ idea: Idea) {
        ideas.removeAll { $0.id == idea.id }
        saveIdeas()
    }
    
    
    func ideasGroupedByDay() -> [(String, [Idea])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        let grouped = Dictionary(grouping: ideas.sorted { $0.timestamp > $1.timestamp }) { idea in
            if calendar.isDate(idea.timestamp, inSameDayAs: today) {
                return "today"
            } else if calendar.isDate(idea.timestamp, inSameDayAs: yesterday) {
                return "yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE, MMM d"
                return formatter.string(from: idea.timestamp).lowercased()
            }
        }
        
        let sortedKeys = grouped.keys.sorted { key1, key2 in
            if key1 == "today" { return true }
            if key2 == "today" { return false }
            if key1 == "yesterday" { return true }
            if key2 == "yesterday" { return false }
            return key1 > key2
        }
        
        return sortedKeys.map { ($0, grouped[$0] ?? []) }
    }
    
    private func saveIdeas() {
        if let encoded = try? JSONEncoder().encode(ideas) {
            userDefaults.set(encoded, forKey: ideasKey)
        }
    }
    
    private func loadIdeas() {
        if let data = userDefaults.data(forKey: ideasKey),
           let decoded = try? JSONDecoder().decode([Idea].self, from: data) {
            ideas = decoded
        }
    }
    
    func getAllCategories() -> [Category] {
        let usedCategories = Set(ideas.map { $0.category })
        let allCategories = Set(Category.defaultCategories).union(usedCategories)
        return Array(allCategories).sorted { $0.name < $1.name }
    }
    
    private func addSampleData() {
        if ideas.isEmpty {
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            
            let sampleIdeas = [
                Idea(text: "make button bigger", category: .work),
                Idea(text: "call mom about dinner", category: .personal),
                Idea(text: "try react query", category: .work),
                Idea(text: "dark mode research", category: .work, timestamp: yesterday),
                Idea(text: "book dentist", category: .personal, timestamp: yesterday)
            ]
            
            ideas.append(contentsOf: sampleIdeas)
            saveIdeas()
        }
    }
}