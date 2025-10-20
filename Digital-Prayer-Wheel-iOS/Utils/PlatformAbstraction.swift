//
//  PlatformAbstraction.swift
//  Digital-Prayer-Wheel
//
//  Platform abstraction protocols
//

import Foundation
import SwiftUI

/// Protocol for platform-specific UI management
protocol PlatformUIManager {
    func setupWindow()
    func setWindowAlwaysOnTop(_ onTop: Bool)
    func showSettings()
    func hideWindow()
}

/// Protocol for platform-specific display capabilities
protocol DisplayProvider {
    var supportsFullScreenOverlay: Bool { get }
    var supportsMenuBar: Bool { get }
    var supportsSplitView: Bool { get }
}

/// Concrete implementation for macOS
#if os(macOS)
    import AppKit

    class MacOSUIManager: PlatformUIManager {
        weak var window: NSWindow?

        init(window: NSWindow? = nil) {
            self.window = window
        }

        func setupWindow() {
            guard let window = window else { return }
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true
            window.isReleasedWhenClosed = false
        }

        func setWindowAlwaysOnTop(_ onTop: Bool) {
            guard let window = window else { return }
            if onTop {
                window.level = .floating
            } else {
                window.level = .normal
            }
        }

        func showSettings() {
            NotificationCenter.default.post(name: NSNotification.Name("OpenSettings"), object: nil)
        }

        func hideWindow() {
            window?.orderOut(nil)
        }
    }

    class MacOSDisplayProvider: DisplayProvider {
        var supportsFullScreenOverlay: Bool { true }
        var supportsMenuBar: Bool { true }
        var supportsSplitView: Bool { false }
    }

#else  // iOS/iPadOS
    import UIKit

    class iOSUIManager: PlatformUIManager {
        weak var viewController: UIViewController?

        init(viewController: UIViewController? = nil) {
            self.viewController = viewController
        }

        func setupWindow() {
            // iOS window setup if needed
        }

        func setWindowAlwaysOnTop(_ onTop: Bool) {
            // iOS doesn't support window leveling, but could use windowScene
        }

        func showSettings() {
            // Post notification or use presentation
            NotificationCenter.default.post(name: NSNotification.Name("OpenSettings"), object: nil)
        }

        func hideWindow() {
            // iOS: navigate away or dismiss
            viewController?.view.window?.isHidden = true
        }
    }

    class iOSDisplayProvider: DisplayProvider {
        var supportsFullScreenOverlay: Bool { true }
        var supportsMenuBar: Bool { false }
        var supportsSplitView: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    }
#endif
