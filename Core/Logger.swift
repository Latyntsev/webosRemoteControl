//
//  Logger.swift
//  webosRemoteControl
//
//  Created by Aleksandr Latyntsev on 8/18/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Foundation

class Logger {

}

class Log {
    let date: Date
    let file: String
    let line: Int
    let function: String

    init(date: Date = .init(), file: String = #file, line: Int = #line, function: String = #function) {
        self.date = date
        self.file = file
        self.line = line
        self.function = function
    }

    func error(_ error: Error) {
        self.error(error.localizedDescription)
    }

    func error(_ error: String) {
        print("❌ \(error)")
    }

    func debug(_ data: Any...) {
        print(data.map({ "\($0)" }).joined(separator: ", "))
    }
}
