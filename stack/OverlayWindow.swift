//
//  OverlayWindow.swift
//  stack
//
//  Created by Kabir Teria on 02/08/25.
//

import Cocoa
import SwiftUI

class OverlayWindow: NSWindow {
    private var overlayViewController: NSHostingController<OverlayView>?
    private var textField: NSTextField!
    private let ideaStore: IdeaStore
    private var isOverlayVisible = false
    
    init(ideaStore: IdeaStore) {
        self.ideaStore = ideaStore
        
        // Create window with proper settings
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 80),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        setupWindow()
        setupNativeTextField()
        setupOverlayView()
    }
    
    private func setupWindow() {
        // Window properties for overlay behavior
        self.backgroundColor = NSColor.clear
        self.isOpaque = false
        self.hasShadow = true
        self.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
        self.isMovable = false
        self.canHide = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        
        // Important: Don't hide when app becomes inactive - this prevents focus stealing
        self.hidesOnDeactivate = false
        
        // Center on current screen
        centerOnCurrentScreen()
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return false
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func becomeKey() {
        super.becomeKey()
        
        // Ensure text field gets focus when window becomes key
        DispatchQueue.main.async {
            self.makeFirstResponder(self.textField)
        }
    }
    
    private func setupNativeTextField() {
        textField = NSTextField()
        textField.isBordered = false
        textField.backgroundColor = NSColor.clear
        textField.textColor = NSColor.white
        textField.font = NSFont.systemFont(ofSize: 15, weight: .regular)
        textField.placeholderString = "what's the idea?"
        textField.target = self
        textField.action = #selector(textFieldAction)
        
        // Remove ugly focus ring
        textField.focusRingType = .none
        
        // Text field will accept first responder by default for NSTextField
        
        // Style the text field completely inline/flat
        textField.wantsLayer = true
        textField.layer?.borderWidth = 1
        textField.layer?.borderColor = NSColor.white.withAlphaComponent(0.3).cgColor
        textField.layer?.cornerRadius = 4
        textField.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.12).cgColor
        
        // Custom cell for better padding and appearance
        let customCell = PaddedTextFieldCell()
        customCell.usesSingleLineMode = true
        customCell.wraps = false
        customCell.isScrollable = true
        customCell.isBordered = false
        customCell.drawsBackground = false
        textField.cell = customCell
        
        // Better placeholder styling with higher opacity
        let placeholderText = NSAttributedString(
            string: "what's the idea?",
            attributes: [
                .foregroundColor: NSColor.white.withAlphaComponent(0.6),
                .font: NSFont.systemFont(ofSize: 15, weight: .regular)
            ]
        )
        textField.placeholderAttributedString = placeholderText
        
        // Position the text field - centered with padding
        textField.frame = NSRect(x: 20, y: 30, width: 460, height: 34)
        self.contentView?.addSubview(textField)
    }
    
    @objc private func textFieldAction() {
        let text = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty {
            saveIdea(text)
        }
        // Always hide overlay after Enter - don't open main app
        hideOverlay()
    }
    
    private func setupOverlayView() {
        // Create a minimal background view with higher opacity and smaller radius
        let backgroundView = NSView()
        backgroundView.wantsLayer = true
        backgroundView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.96).cgColor
        backgroundView.layer?.cornerRadius = 6
        
        self.contentView = backgroundView
        
        // Add text field on top
        backgroundView.addSubview(textField)
        
        // Add minimal hint label
        let hintLabel = NSTextField()
        hintLabel.isEditable = false
        hintLabel.isSelectable = false
        hintLabel.isBordered = false
        hintLabel.backgroundColor = NSColor.clear
        hintLabel.textColor = NSColor.white.withAlphaComponent(0.3)
        hintLabel.font = NSFont.systemFont(ofSize: 10, weight: .regular)
        hintLabel.stringValue = "enter to save • esc to cancel"
        hintLabel.alignment = .center
        hintLabel.frame = NSRect(x: 20, y: 8, width: 460, height: 14)
        backgroundView.addSubview(hintLabel)
    }
    
    private func centerOnCurrentScreen() {
        guard let screen = NSScreen.main else { return }
        
        let screenFrame = screen.frame
        let windowSize = self.frame.size
        
        let x = screenFrame.midX - windowSize.width / 2
        // Position in top half of screen (75% from bottom)
        let y = screenFrame.minY + screenFrame.height * 0.75 - windowSize.height / 2
        
        self.setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    func toggleOverlay() {
        if isOverlayVisible {
            hideOverlay()
        } else {
            showOverlay()
        }
    }
    
    func showOverlay() {
        // Prevent multiple overlays
        guard !isOverlayVisible else { return }
        
        isOverlayVisible = true
        
        centerOnCurrentScreen()
        
        // Clear text field first
        textField.stringValue = ""
        
        // Make the window key without activating the app
        self.makeKeyAndOrderFront(nil)
        
        // Force focus on the text field using multiple approaches
        DispatchQueue.main.async {
            // Make sure the window is key
            self.makeKey()
            
            // Focus the text field aggressively
            self.makeFirstResponder(self.textField)
            
            // Additional focus enforcement
            self.textField.becomeFirstResponder()
            
            // Force the window to accept first responder
            if self.textField.acceptsFirstResponder {
                self.textField.window?.makeFirstResponder(self.textField)
            }
        }
    }
    
    func hideOverlay() {
        guard isOverlayVisible else { return }
        
        isOverlayVisible = false
        self.orderOut(nil)
        
        // Just hide - don't try to return focus to avoid activating our main app
        // The system will naturally return focus to the previously active app
    }
    
    private func saveIdea(_ text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let (cleanText, category) = Category.parse(from: trimmedText)
        let newIdea = Idea(text: cleanText, category: category)
        ideaStore.addIdea(newIdea)
        
        // Don't activate the main app - just save silently
        print("Idea saved: \(cleanText) [\(category.name)]")
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape key
            hideOverlay()
        } else {
            // Forward all other keys to the SwiftUI view
            super.keyDown(with: event)
        }
    }
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.keyCode == 53 { // Escape key
            hideOverlay()
            return true
        }
        return super.performKeyEquivalent(with: event)
    }
}


// Custom text field cell with proper padding
class PaddedTextFieldCell: NSTextFieldCell {
    private let padding: CGFloat = 12
    
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        return rect.insetBy(dx: padding, dy: 0)
    }
    
    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        let paddedRect = rect.insetBy(dx: padding, dy: 0)
        super.select(withFrame: paddedRect, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
}