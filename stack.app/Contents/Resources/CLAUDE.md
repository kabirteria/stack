# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Stack is a minimal friction idea capture app for macOS. Core philosophy: preserve flow state at all costs. The app enables users to capture ideas in under 3 seconds via global hotkey without losing focus from their current work.

**Key User Flow**: `Cmd+Shift+S` → overlay appears → type idea → `Enter` → back to work instantly.

## Development Commands

### Building and Running
- **Build**: Use Xcode's build command (⌘+B) or `xcodebuild build`
- **Run**: Use Xcode's run command (⌘+R) 
- **Clean**: Use Xcode's clean command (⌘+⇧+K) or `xcodebuild clean`

### Testing
- **Run All Tests**: Use Xcode's test command (⌘+U) or `xcodebuild test`
- **Run Specific Test**: `xcodebuild test -only-testing:stackTests/stackTests/testName`

Uses Swift Testing framework (not XCTest) - look for `@Test` attributes and `import Testing`.

### macOS-Specific Development
- **Test Global Hotkeys**: Run app and verify `Cmd+Shift+S` triggers overlay from any app
- **Check Permissions**: App requires Accessibility permissions for global event monitoring
- **Window Positioning**: Test overlay appears centered on current screen, not main screen

## Architecture

### Core Data Models
```swift
struct Idea {
    let id: UUID
    let text: String
    let timestamp: Date
    let category: Category
    let context: String? // app user was in when captured
    var isCompleted: Bool
}

enum Category: String, CaseIterable {
    case work = "work"
    case personal = "personal" 
    case random = "random"
}
```

### Key Technical Components

**Global Event Monitoring** (`stackApp.swift`)
- Monitors `Cmd+Shift+S` system-wide using Carbon/Cocoa APIs
- Must work from any app (VSCode, Figma, browsers)
- Requires Accessibility permissions

**Capture Overlay** (`ContentView.swift` or separate overlay view)
- Floating window that appears over current app
- Dark mode by default (less jarring)
- Auto-focuses text field, saves on Enter, cancels on Esc
- Must not steal focus from original app permanently

**Main App Window**
- List view grouped by day
- Simple categories (work/personal/random)
- Search functionality
- Clean, minimal design

**Data Persistence**
- Start with UserDefaults for MVP
- Consider Core Data for advanced features
- Store with timestamp + auto-detected context

### macOS-Specific Considerations
- **App Sandbox**: Currently enabled - may need to disable for global hotkeys
- **Hardened Runtime**: Enabled - ensure compatibility with event monitoring
- **Deployment Target**: macOS 15.2+
- **Bundle ID**: `com.kabir.test.stack`

### UX Performance Requirements
- **Critical**: Capture experience under 3 seconds
- **Critical**: Zero visual distraction during capture
- **Critical**: Never lose focus of original app
- **Important**: Smooth fade in/out animations
- **Important**: Keyboard navigation in main window

### Current Implementation Status
Basic SwiftUI app with placeholder UI. Next priorities:
1. Global hotkey implementation
2. Overlay window creation
3. Data model implementation
4. Persistence layer

### Development Learning Goals
This project teaches:
- Global event monitoring (Carbon/Cocoa integration)
- Advanced window management (overlay positioning)
- SwiftUI state management with external events
- macOS app lifecycle and permissions
- Performance-critical UX implementation

## Development Guidelines
- Always use lowercase letters for everything in the frontend of the app