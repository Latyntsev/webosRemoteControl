//
//  Keyboard.swift
//  macOS
//
//  Created by Aleksandr Latyntsev on 9/8/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Foundation

protocol KeyboardHandlerItemProtocol {
    func execute() -> Bool
}
struct KeyboardHandlerItem<T: AnyObject>: KeyboardHandlerItemProtocol {
    weak var owner: T?
    var handler: (T) -> Void
    func execute() -> Bool {
        guard let owner = owner else { return false }
        handler(owner)
        return true
    }
}

final class Keyboard {
    static let shared = Keyboard()
    var handlers: [UInt16: [KeyboardHandlerItemProtocol]] = [:]

    func subscribe<T:AnyObject>(keyCode: UInt16, owner: T, handler: @escaping (T) -> Void) {
        var items = handlers[keyCode] ?? []
        items.append(KeyboardHandlerItem(owner: owner, handler: handler))
        handlers[keyCode] = items
    }

    func keyDown(keyCode: UInt16) {
        handlers[keyCode] = handlers[keyCode]?.filter({ $0.execute() })
    }
}
