//
//  WebSocketWrapper.swift
//  webosRemoteControl
//
//  Created by Aleksandr Latyntsev on 11/13/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Foundation
import Starscream
import PromiseKit

class WebSocketWrapper {
    private var webSocket: WebSocket!
    var url: URL
    var timeout: TimeInterval
    var allowSelfSigned: Bool
    var onEvent: ((WebSocketEvent) -> Void)?
    var reconnectDependency: ((WebSocketWrapper, @escaping (Bool) -> Void) -> Void)?

    init(_ url: URL, timeout: TimeInterval = 5, allowSelfSigned: Bool = false) {
        self.url = url
        self.timeout = timeout
        self.allowSelfSigned = allowSelfSigned
        self.createSocket()
    }

    private func createSocket() {
        webSocket?.onEvent = nil
        var request = URLRequest(url: url)
        request.timeoutInterval = timeout
        request.addValue("chrome-extension://remote-control", forHTTPHeaderField: "Origin")
        let certPinner = FoundationSecurity(allowSelfSigned: allowSelfSigned)
        webSocket = WebSocket(request: request, certPinner: certPinner)
        webSocket.onEvent = { [weak self] in
            self?.eventHandler($0)
            self?.onEvent?($0)
        }
    }

    private func recreateSocket(callback: @escaping (Bool) -> Void) -> Void {
        guard let reconnectDependency = reconnectDependency else {
            createSocket()
            callback(true)
            return
        }

        reconnectDependency(self, {
            if $0 {
                self.createSocket()
            }
            callback($0)
        })
    }

    private func eventHandler(_ event: WebSocketEvent) {
        switch event {
        case .disconnected, .cancelled, .error:
            tryReconnect()
        case .viabilityChanged(let viability):
            guard !viability else { break }
            tryReconnect()
        default:
            break
        }
    }
    var reconnectInProgress = false
    private func tryReconnect() {
        guard !reconnectInProgress else { return }
        reconnectInProgress = true
        print("tryReconnect")
        after(seconds: 1).done({
            self.recreateSocket(callback: {
                if $0 {
                    self.connect()
                }
                self.reconnectInProgress = false
            })
        })
    }

    func connect() {
        webSocket.connect()
    }

    func disconnect(closeCode: UInt16 = CloseCode.normal.rawValue) {
        webSocket.disconnect(closeCode: closeCode)
    }

    func write(string: String) {
        webSocket.write(string: string)
    }
}
