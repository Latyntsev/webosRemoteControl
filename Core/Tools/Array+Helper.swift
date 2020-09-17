//
//  Array+Helper.swift
//  RemoteControl
//
//  Created by Aleksandr Latyntsev on 7/30/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0 else { return nil }
        guard index < count else { return nil }
        return self[index]
    }
}
