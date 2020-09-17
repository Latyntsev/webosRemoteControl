//
//  BaseWindow.swift
//  macOS
//
//  Created by Aleksandr Latyntsev on 9/8/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Cocoa

class BaseWindow: NSWindow {
    override func keyDown(with event: NSEvent) {
//        super.keyDown(with: event)
        Keyboard.shared.keyDown(keyCode: event.keyCode)
        Log().debug(event)
    }
}

