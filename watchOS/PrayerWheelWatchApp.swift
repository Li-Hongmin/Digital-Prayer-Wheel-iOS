//
//  PrayerWheelWatchApp.swift
//  Digital Prayer Wheel Watch App
//
//  Created by Claude on 2025/11/09.
//

import SwiftUI
import WatchKit

@main
struct PrayerWheelWatchApp: App {
    @WKApplicationDelegateAdaptor(ExtensionDelegate.self) var extensionDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Extension Delegate for background tasks
class ExtensionDelegate: NSObject, WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        // Configure app on launch
        print("Prayer Wheel Watch App launched")
    }

    func applicationWillResignActive() {
        // Save state when app goes to background
        print("App will resign active")
    }

    func applicationDidBecomeActive() {
        // Restore state when app becomes active
        print("App did become active")
    }
}
