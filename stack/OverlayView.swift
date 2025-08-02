//
//  OverlayView.swift
//  stack
//
//  Created by Kabir Teria on 02/08/25.
//

import SwiftUI

struct OverlayView: View {
    @State private var ideaText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    let onSave: (String) -> Void
    let onCancel: () -> Void
    
    private func handleSave() {
        let trimmedText = ideaText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty {
            onSave(trimmedText)
        } else {
            onCancel()
        }
        ideaText = "" // Clear text after action
    }
    
    private func handleCancel() {
        ideaText = "" // Clear text on cancel
        onCancel()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content
            VStack(spacing: 16) {
                // Text field
                TextField("", text: $ideaText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(.white)
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        handleSave()
                    }
                    .overlay(
                        // Custom placeholder
                        Group {
                            if ideaText.isEmpty {
                                HStack {
                                    Text("what's the idea?")
                                        .foregroundColor(.white.opacity(0.5))
                                        .font(.system(size: 16, weight: .regular, design: .default))
                                    Spacer()
                                }
                            }
                        }
                    )
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.2))
                            .stroke(isTextFieldFocused ? Color.white.opacity(0.6) : Color.white.opacity(0.4), lineWidth: 1)
                    )
                
                // Hint text
                Text("press enter to save • esc to cancel • option+s to toggle")
                    .font(.system(size: 11, weight: .regular, design: .default))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(30)
        }
        .frame(minWidth: 550, minHeight: 120)
        .background(
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.black.opacity(0.98))
                .shadow(color: .black.opacity(0.4), radius: 25, x: 0, y: 12)
        )
        .onAppear {
            // Auto-focus when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isTextFieldFocused = true
            }
        }
    }
}