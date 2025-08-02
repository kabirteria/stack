//
//  AppDelegate.swift
//  stack
//
//  Created by Kabir Teria on 02/08/25.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var overlayWindow: OverlayWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Stack app launched - setting up global hotkey system")
        setupOverlayWindow()
        setupGlobalHotkey()
    }
    
    private func setupOverlayWindow() {
        overlayWindow = OverlayWindow(ideaStore: IdeaStore.shared)
        
        // Set up hotkey callback
        GlobalHotkeyManager.shared.onHotkeyPressed = { [weak self] in
            self?.overlayWindow?.toggleOverlay()
        }
    }
    
    private func setupGlobalHotkey() {
        // Check for accessibility permissions
        let hasPermissions = GlobalHotkeyManager.shared.checkAccessibilityPermissions()
        print("Accessibility permissions granted: \(hasPermissions)")
        
        if hasPermissions {
            print("Registering global hotkey Option+S")
            GlobalHotkeyManager.shared.registerHotkey()
        } else {
            print("Accessibility permissions needed - showing dialog")
            // Show permission request dialog
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.showAccessibilityPermissionAlert()
            }
        }
    }
    
    private func showAccessibilityPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "Stack needs accessibility permissions to capture ideas globally with Option+S. Please grant permission in System Preferences > Privacy & Security > Accessibility."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Later")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Keep app running even when main window is closed
    }
}