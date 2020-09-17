//
//  UDPDatagram.swift
//  webosRemoteControl
//
//  Created by Aleksandr Latyntsev on 8/18/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Foundation

extension UDPDatagram {
    struct Headers {
        var values = [(key: String, value: String)]()
        subscript(_ key: String) -> String? {
            get {
                values.first(where: { $0.key == key })?.value
            }
            set {
                guard let newValue = newValue else {
                    values.removeAll(where: { $0.key == key }) // remove value
                    return
                }
                guard let index = values.firstIndex(where: { $0.key == key }) else {
                    values.append((key, newValue)) // add value
                    return
                }
                values[index] = (key, newValue) // update value
            }
        }
    }
}


struct UDPDatagram {
    var protocolAndVersion: String?
    let path: String?
    var method: String?
    var statusCode: String?
    var statusMessage: String?
    var headers = Headers()

    init(method: String) {
        self.method = method
        self.protocolAndVersion = "HTTP/1.1"
        self.path = "*"
    }

    init(receivedData string: String) {
        self.path = nil
        self.method = nil
        var lines = string.components(separatedBy: "\r\n")
        if let firstLine = lines.first?.components(separatedBy: " ") {
            self.protocolAndVersion = firstLine[safe: 0]
            self.statusCode = firstLine[safe: 1]
            self.statusMessage = firstLine[safe: 2]
            lines.remove(at: 0)
        }
        lines.forEach({
            let components = $0.components(separatedBy: ": ")
            guard !components.isEmpty else { return }
            headers[components[0]] = components[safe: 1]
        })
    }


    func toString() -> String {
        let headersList = headers.values.map({ "\($0.key): \($0.value)" })
        let lines = ["M-SEARCH * HTTP/1.1"] + headersList + ["", ""]
        return lines.joined(separator: "\r\n")
    }

}
