//
//  BodyProtocol.swift
//  RemoteControl
//
//  Created by Aleksandr Latyntsev on 7/30/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Foundation

protocol BodyProtocol {
    func generateBody() throws -> Data?
}

extension Data: BodyProtocol {
    func generateBody() throws -> Data? {
        self
    }
}

extension String: BodyProtocol {
    func generateBody() throws -> Data? {
        data(using: .utf8)
    }
}

extension Dictionary: BodyProtocol where Key == String, Value == Any {
    func generateBody() throws -> Data? {
        try JSONSerialization.data(withJSONObject: self, options: .init(rawValue: 0))
    }
}

extension Array: BodyProtocol where Element == Any {
    func generateBody() throws -> Data? {
        try JSONSerialization.data(withJSONObject: self, options: .init(rawValue: 0))
    }
}
