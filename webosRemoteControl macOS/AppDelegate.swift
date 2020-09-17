//
//  AppDelegate.swift
//  webosRemoteControl macOS
//
//  Created by Aleksandr Latyntsev on 8/18/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var dataProvider = DataProvider()
    var tasks: [Task] = []
    var activateAppHoteKey:

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
