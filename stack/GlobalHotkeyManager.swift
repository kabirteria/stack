//
//  GlobalHotkeyManager.swift
//  stack
//
//  Created by Kabir Teria on 02/08/25.
//

import Cocoa
import Carbon

class GlobalHotkeyManager: ObservableObject {
    static let shared = GlobalHotkeyManager()
    
    private var hotKeyRef: EventHotKeyRef?
    private let hotkeyId: EventHotKeyID = EventHotKeyID(signature: 0x73746b20, id: 1) // 'stk '
    
    var onHotkeyPressed: (() -> Void)?
    
    private init() {}
    
    func registerHotkey() {
        print("Attempting to register global hotkey Option+S...")
        
        // Register Option+S (Option/Alt key as modifier)
        let modifiers = UInt32(optionKey)
        let keyCode = UInt32(kVK_ANSI_S)
        
        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)
        
        let handlerResult = InstallEventHandler(
            GetEventDispatcherTarget(),
            { (nextHandler, theEvent, userData) -> OSStatus in
                guard let userData = userData else { return noErr }
                let manager = Unmanaged<GlobalHotkeyManager>.fromOpaque(userData).takeUnretainedValue()
                manager.hotkeyPressed()
                return noErr
            },
            1,
            &eventType,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            nil
        )
        
        print("Event handler installation result: \(handlerResult)")
        
        let registerResult = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotkeyId,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )
        
        print("Hotkey registration result: \(registerResult)")
        
        if registerResult == noErr {
            print("✅ Global hotkey Option+S registered successfully!")
        } else {
            print("❌ Failed to register global hotkey. Error code: \(registerResult)")
        }
    }
    
    func unregisterHotkey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
    }
    
    private func hotkeyPressed() {
        print("Global hotkey Option+S pressed!")
        DispatchQueue.main.async {
            self.onHotkeyPressed?()
        }
    }
    
    func checkAccessibilityPermissions() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
}