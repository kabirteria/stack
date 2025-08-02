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
        VStack(spacing: 16) {
            textFieldView
            hintTextView
        }
        .padding(30)
        .frame(minWidth: 550, minHeight: 120)
        .background(backgroundView)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isTextFieldFocused = true
            }
        }
    }
    
    private var textFieldView: some View {
        TextField("what's the idea?", text: $ideaText)
            .textFieldStyle(PlainTextFieldStyle())
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(.white)
            .focused($isTextFieldFocused)
            .onSubmit {
                handleSave()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(textFieldBackground)
    }
    
    private var textFieldBackground: some View {
        RoundedRectangle(cornerRadius: 2)
            .foregroundColor(Color.white.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(strokeColor, lineWidth: 1)
            )
    }
    
    private var strokeColor: Color {
        isTextFieldFocused ? Color.white.opacity(0.6) : Color.white.opacity(0.4)
    }
    
    private var hintTextView: some View {
        Text("press enter to save • esc to cancel • option+s to toggle")
            .font(.system(size: 11, weight: .regular))
            .foregroundColor(.white.opacity(0.4))
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 3)
            .foregroundColor(Color.black.opacity(0.98))
            .shadow(color: .black.opacity(0.4), radius: 25, x: 0, y: 12)
    }
}