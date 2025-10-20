//
//  PlatformDefines.swift
//  Digital-Prayer-Wheel
//
//  Platform-specific definitions and utilities
//

import Foundation

#if os(macOS)
    import AppKit
    typealias PlatformColor = NSColor
    typealias PlatformFont = NSFont
    typealias PlatformImage = NSImage
    typealias PlatformViewController = NSViewController

    let isCompact = false  // macOS uses full-size windows
    let isPhone = false
    let isPad = false
    let isMacOS = true

#else  // iOS/iPadOS
    import UIKit
    typealias PlatformColor = UIColor
    typealias PlatformFont = UIFont
    typealias PlatformImage = UIImage
    typealias PlatformViewController = UIViewController

    let isCompact = true   // iOS uses compact layouts
    let isPhone = UIDevice.current.userInterfaceIdiom == .phone
    let isPad = UIDevice.current.userInterfaceIdiom == .pad
    let isMacOS = false
#endif

/// Platform capability detection
struct PlatformCapabilities {
    static let supportsMenuBar = isMacOS
    static let supportsStatusItem = isMacOS
    static let supportsFullScreenOverlay = isMacOS
    static let requiresPortraitLayout = isPhone
    static let supportsMultiWindowLayout = isPad || isMacOS
}
