# Stack - Minimal Idea Capture

A beautifully minimal macOS app for capturing ideas instantly without breaking your flow state.

## Philosophy

**Minimal friction idea capture. Zero cognitive load. Preserve flow state at all costs.**

Stack is designed for developers, designers, writers, and anyone who gets interrupted by their own brain. Capture thoughts in under 3 seconds and get back to what matters.

## Features

### Core Functionality
- **Instant capture**: Seamless input field - just start typing
- **Smart categorization**: Use `:work`, `:personal`, or `:random` to tag ideas
- **Keyboard navigation**: Arrow keys to navigate category suggestions
- **One-handed operation**: Enter to save, Escape to cancel
- **Automatic grouping**: Ideas organized by day (today, yesterday, etc.)

### User Experience
- **Clean typography**: Readable fonts with perfect spacing
- **Dark/Light themes**: Toggle with sun/moon icon in bottom corner
- **Hover interactions**: Timestamps and delete options appear on hover
- **Smooth animations**: Gentle transitions that don't distract
- **Centered layout**: App takes 60% of screen width for focused experience

### Technical Details
- **Native macOS**: Built with SwiftUI for macOS 15.2+
- **Hidden title bar**: Seamless black interface
- **Local storage**: Uses UserDefaults for persistence
- **Swift Testing**: Modern testing framework integration

## Getting Started

### Requirements
- macOS 15.2 or later
- Xcode 16.2 or later

### Installation
1. Clone this repository
2. Open `stack.xcodeproj` in Xcode
3. Build and run (⌘+R)

### Usage
1. **Capture ideas**: Just start typing in the input field
2. **Add categories**: Type `:work` or `:personal` at the end of your idea
3. **Navigate suggestions**: Use arrow keys to select categories
4. **Review ideas**: Scroll through your captured thoughts
5. **Manage ideas**: Hover over items to see timestamps and delete options
6. **Switch themes**: Click the sun/moon icon in the bottom right

## User Flows

### Quick Capture (Primary Use Case)
1. User is working in any app
2. Idea pops up: "what if we made this button bigger"
3. Focus Stack app → small overlay appears
4. User types idea, hits enter
5. User back to work in <3 seconds
6. Idea saved with timestamp

### Review Session
1. Open Stack app
2. See clean list of captured ideas
3. Can categorize, mark as done, or delete
4. Ideas grouped by day for easy browsing

## Data Model

```swift
struct Idea {
    let id: UUID
    let text: String
    let timestamp: Date
    let category: Category
    let context: String? // Future: app user was in when captured
}

enum Category {
    case work, personal, random
    // Plus any custom categories created by user
}
```

## Development

### Project Structure
```
stack/
├── Models/
│   ├── Idea.swift          # Core idea data structure
│   ├── Category.swift      # Category handling with parsing
│   └── IdeaStore.swift     # ObservableObject for state management
├── Views/
│   └── ContentView.swift   # Main interface
├── stackApp.swift          # App entry point
└── Assets.xcassets/        # App icons and colors
```

### Key Features Implementation
- **Smart placeholders**: Rotating placeholder text every 3 seconds
- **Category parsing**: `:category` syntax automatically detected
- **Keyboard navigation**: Full arrow key support in dropdowns
- **Theme switching**: Smooth transitions between light/dark modes
- **Hover states**: Subtle interactions without visual clutter

### Testing
Run tests with:
```bash
xcodebuild test
```

### Performance Goals
- Capture time consistently under 3 seconds
- No crashes or missed input events
- Smooth 60fps animations
- Minimal memory footprint

## Success Metrics

The app succeeds when:
- You actually use it daily
- Capture time stays under 3 seconds
- Interface stays clean and distraction-free
- Ideas feel organized and accessible

## Contributing

This is a personal productivity tool, but suggestions and improvements are welcome:

1. Fork the repository
2. Create a feature branch
3. Make changes with proper commit messages
4. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Credits

Built with ❤️ by Kabir Teria
- Minimal design philosophy inspired by writing apps like iA Writer
- SwiftUI for native macOS experience
- Icons from SF Symbols

---

*"The best capture tool is the one you actually use"*