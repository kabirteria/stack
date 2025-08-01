//
//  Idea.swift
//  stack
//
//  Created by Kabir Teria on 02/08/25.
//

import Foundation

struct Idea: Identifiable, Codable {
    let id: UUID
    let text: String
    let timestamp: Date
    let category: Category
    let context: String?
    
    init(text: String, category: Category, context: String? = nil, timestamp: Date = Date()) {
        self.id = UUID()
        self.text = text
        self.timestamp = timestamp
        self.category = category
        self.context = context
    }
}