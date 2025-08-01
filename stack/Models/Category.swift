//
//  Category.swift
//  stack
//
//  Created by Kabir Teria on 02/08/25.
//

import Foundation

struct Category: Codable, Hashable {
    let name: String
    
    static let work = Category(name: "work")
    static let personal = Category(name: "personal")
    static let random = Category(name: "random")
    
    static let defaultCategories = [work, personal, random]
}

extension Category {
    static func parse(from text: String) -> (cleanText: String, category: Category) {
        let components = text.components(separatedBy: ":")
        
        if components.count >= 2 {
            let categoryName = components.last?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? "random"
            let cleanText = components.dropLast().joined(separator: ":").trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !cleanText.isEmpty && !categoryName.isEmpty {
                return (cleanText, Category(name: categoryName))
            }
        }
        
        return (text, Category.random)
    }
}