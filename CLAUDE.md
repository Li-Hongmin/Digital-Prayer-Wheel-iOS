# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Digital Prayer Wheel iOS** is a Buddhist prayer counting application for iOS/iPadOS that helps practitioners track their recitation of various Buddhist mantras and sutras. The app features a rotating prayer wheel interface, customizable display settings, and persistent counting across multiple prayer types.

## Build, Test & Development Commands

### Building
```bash
# Build for iOS device
xcodebuild -scheme Digital-Prayer-Wheel-iOS -configuration Debug

# Build for iOS Simulator
xcodebuild -scheme Digital-Prayer-Wheel-iOS -configuration Debug -sdk iphonesimulator

# Build for iPad
xcodebuild -scheme Digital-Prayer-Wheel-iOS -configuration Debug -destination 'platform=iOS Simulator,name=iPad'
```

### Running in Simulator
```bash
# Build and run on default iOS simulator
xcodebuild -scheme Digital-Prayer-Wheel-iOS -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15'

# Run on iPad simulator
xcodebuild -scheme Digital-Prayer-Wheel-iOS -configuration Debug -destination 'platform=iOS Simulator,name=iPad Pro 11-inch'
```

### Linting & Code Quality
```bash
# SwiftLint (if installed)
swiftlint
```

### Cleaning
```bash
# Clean build directory
xcodebuild clean
rm -rf ~/Library/Developer/Xcode/DerivedData/Digital*
```

## Architecture Overview

### Core Patterns

**MVVM + Observable Objects**: The app uses SwiftUI's `ObservableObject` protocol for reactive state management:
- `AppSettings`: Global app settings (barrage display mode, speed, opacity, etc.)
- `PrayerLibrary`: Prayer data and counting logic (uses exponential growth for counts)

**Platform Abstraction**: Support for both iPhone and iPad through:
- `PlatformDefines.swift`: Conditional compilation for iOS/macOS with device-specific type aliases
- `PlatformAbstraction.swift`: Runtime device detection (phone vs. tablet layouts)
- Platform-specific views: `iOSPrayerWheelView` (iPhone), `iPadPrayerWheelView` (iPad)

### Directory Structure

```
Digital-Prayer-Wheel-iOS/
├── Models/
│   ├── AppSettings.swift        # User settings (display, speed, opacity)
│   └── PrayerText.swift         # Prayer enum with text content (4 types)
├── Services/
│   └── PrayerLibrary.swift      # Prayer logic, counting, persistence
├── Views/
│   ├── iOSApp.swift             # App entry point
│   ├── iOSContentView.swift     # Main container (iPhone/iPad routing)
│   ├── iOSPrayerWheelView.swift # iPhone prayer wheel UI
│   ├── iPadPrayerWheelView.swift# iPad prayer wheel UI
│   └── iOSSettingsView.swift    # Settings sheet
└── Utils/
    ├── PlatformDefines.swift    # Conditional compilation & device detection
    └── PlatformAbstraction.swift# Platform capability checks
```

### Data Flow

1. **App Entry**: `DigitalPrayerWheelIOSApp` → `iOSContentView`
2. **Device Detection**: `iOSContentView` checks `UIDevice.userInterfaceIdiom` → routes to iPhone or iPad view
3. **State Management**:
   - `AppSettings` (EnvironmentObject): Barrage display settings
   - `PrayerLibrary` (StateObject): Prayer text cycling, counting logic
4. **Data Persistence**: Both objects auto-save to `UserDefaults` on state changes
5. **Settings Flow**: Modal sheet presentation on settings button tap

### Key Components

#### PrayerLibrary (Services/PrayerLibrary.swift)
**Exponential Growth Counting System**:
- Stores count as exponent: `currentCount = 2^countExponent`
- Each call to `getNextText()` increments exponent (+1 each time)
- Tracks total cycles separately: `totalCycles` (simple +1 per text fetch)
- Max limit: exponent resets to 0 when exceeds 235 (2^236 ≈ 1.2×10^71)
- Caches computed Decimal values to avoid repeated exponentiation

**Chinese Unit Formatting**:
- Custom unit system: 万(10K), 亿(100M), 兆(1T), 京, 垓, 秭, 穣, 溝, 澗, 正, 載, 極, 恒河沙, 阿僧祇, 那由他, 不可思議, 無量數
- Two formatting methods: `formatCountWithChineseUnits()`, `formatCountWithChineseUnitsSeparated()`

**Data Structure**:
- 4 Prayer Types: Mantra (六字大明咒), Heart Sutra (心经), Amitabha (南无阿弥陀佛), Guanyin (南无观世音菩萨)
- Heart Sutra has 35 lines; others are single-line mantras
- Per-type storage in UserDefaults with keys: `PrayerCount_[type]`, `TotalCycles_[type]`

#### AppSettings (Models/AppSettings.swift)
**Barrage (Danmaku) Configuration**:
- Display type: fullscreen or bottom
- Speed: 0-100+ (arbitrary units)
- Direction: rightToLeft, leftToRight, topToBottom, bottomToTop
- Font size: 0-100+ points
- Opacity: 0.0-1.0
- Interval: slider 0-100 maps exponentially to 0.001-10 seconds

**Persistence**: Auto-saves to UserDefaults on property change via `didSet`

#### View Architecture
- **iOSContentView**: Root view, device detection, settings sheet presentation
- **iOSPrayerWheelView**: iPhone portrait layout with prayer wheel animation
- **iPadPrayerWheelView**: Horizontal layout for larger screens
- **iOSSettingsView**: Settings modal with controls for all AppSettings properties

### State Management Notes

1. **@Published properties** trigger UI updates automatically via SwiftUI
2. **@StateObject** in views ensures single instance per view lifetime
3. **@EnvironmentObject** can be used but currently passed as parameters
4. **UserDefaults synchronization**: Triggered on didSet, can cause repeated writes during rapid state changes
5. **Cache invalidation**: PrayerLibrary manually clears `cachedCount` when exponent changes

## Recent Changes & Ongoing Work

### Recent Fixes (Git History)
- `990191e`: Fix total cycles display issue
- `95bb71d`: Add Combine import to view files (required for @Published)
- `b62789d`: Fix iOS compilation errors (platform-specific code)
- `75e4bdd`: Initial commit

### Known Status
- iOS app builds and runs on iPhone/iPad simulators
- All compilation errors resolved with Combine import fixes
- Platform abstraction allows future macOS port support

## Important Development Notes

### Combine Framework Integration
All observable models require `import Combine` for `@Published` and `ObservableObject`. Recent commits show this was missing in view files initially.

### Device Detection
Runtime detection in Views (not compile-time), allows testing both layouts on same device:
```swift
if UIDevice.current.userInterfaceIdiom == .pad { ... }
```

### Exponential Count System Reasoning
The complex exponential growth mechanics serve spiritual purposes—practitioners experience acceleration in their visible counting, creating psychological momentum and perceived progress.

### UserDefaults Limitations
Current implementation uses flat key-value storage. Consider alternatives (SwiftData, Core Data) if:
- Need versioning/migration strategies
- Want relational data structures
- Need query capabilities beyond simple key lookup

### View File Organization
Views are organized by platform/device type (iOS, iPad) rather than feature. Consider reorganizing by feature if adding more prayer types or UI variations.
