//
//  AppDelegate.swift
//  webosRemoteControl macOS
//
//  Created by Aleksandr Latyntsev on 8/18/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Cocoa
import HotKey

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var activateAppHotKey: HotKey?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        activateAppHotKey = HotKey(key: .tab,
                                   modifiers: [.command, .shift],
                                   keyDownHandler: { [weak self] in self?.activate() })
    }

    func activate() {
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

