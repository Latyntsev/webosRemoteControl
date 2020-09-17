//
//  WebOSCommunicator.swift
//  webosRemoteControl
//
//  Created by Aleksandr Latyntsev on 8/18/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Foundation
import Starscream
import PromiseKit
import SwiftyJSON

class WebOSCommunicator {

    enum RegisterState {
        case checking
        case registration
        case registered

    }
    typealias ResponseHandlerType = (JSON) -> Bool
    var stateChangeHandler: ((State) -> Void)?
    var registerStateChangedHandler: ((RegisterState) -> Void)?
    var state = State() {
        didSet {
            stateChangeHandler?(state)
        }
    }

    let uuid: String
    let host: String
    let port: Int = 3001
    private var storage: SimpleStorage
    private var key: String?
    private var tvWebSocket: WebSocket?
    private var inputWebSocket: WebSocket?
    private var responseHandlers = [String: ResponseHandlerType]()
    private var idCounter = 0

    init(uuid: String, host: String, storage: SimpleStorage = .shared) {
        self.uuid = uuid
        self.host = host
        self.storage = storage
        self.key = storage["client-key-\(uuid)"]
    }

    func connect() {
        registerStateChangedHandler?(.checking)
        var request = URLRequest(url: URL(string: "wss://\(host):\(port)")!)
        request.timeoutInterval = 5
        request.addValue("chrome-extension://remote-control", forHTTPHeaderField: "Origin")
        let pinner = FoundationSecurity(allowSelfSigned: true)
        tvWebSocket = WebSocket(request: request, certPinner: pinner)
        tvWebSocket?.onEvent = { [weak self] in
            self?.onEvent($0)
        }
        tvWebSocket?.connect()
    }

    private func onEvent(_ event: WebSocketEvent) {
        switch event {
        case .connected:
            register()

        case .text(let text):
            Log().debug(JSON(parseJSON: text))
            processIncomingMessage(JSON(parseJSON: text))
        case .disconnected(let message, let code):
            Log().debug("Disconnected", message, code)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.tvWebSocket?.connect()
            }
        default:
            Log().debug(event)
            break
        }
    }

    private func processIncomingMessage(_ json: JSON) {
        let id = json["id"].stringValue
        guard let handler = responseHandlers[id] else {
            Log().error("response can't be processed")
            return
        }
        if handler(json) {
            responseHandlers[id] = nil
        }
    }

    private func sendMessage(_ json: JSON, _ responseHandler: @escaping ResponseHandlerType) {
        idCounter += 1
        let id = "id_\(idCounter)_\(Date().timeIntervalSince1970)"
        var json = json
        json["id"].stringValue = id

        guard let text = json.rawString() else {
            assert(false, "Can't generate JSON")
            return
        }
        Log().debug("---write---")
        Log().debug(text)
        responseHandlers[id] = responseHandler
        tvWebSocket?.write(string: text)
    }

    private func subscribe(uri: String, payload: JSON = [:], _ responseHandler: @escaping (JSON) -> Void) {
        var json = JSON()
        json["type"].string = "subscribe"
        json["uri"].string = uri
        json["payload"] = payload
        sendMessage(json) {
            responseHandler($0)
            return false
        }
    }

    private func request(uri: String, payload: JSON = [:], _ responseHandler: @escaping (JSON) -> Void) {
        var json = JSON()
        json["type"].string = "request"
        json["uri"].string = uri
        json["payload"] = payload
        sendMessage(json) {
            responseHandler($0)
            return true
        }
    }

    private func register() {
        let message = """
        {"type":"register","payload":{
          "forcePairing": false,
          "pairingType": "PROMPT",
          "manifest": {
            "manifestVersion": 1,
            "appVersion": "1.1",
            "signed": {
              "created": "20140509",
              "appId": "com.lge.test",
              "vendorId": "com.lge",
              "localizedAppNames": {
                "": "LG Remote App",
                "ko-KR": "리모컨 앱",
                "zxx-XX": "ЛГ Rэмotэ AПП"
              },
              "localizedVendorNames": {
                "": "LG Electronics"
              },
              "permissions": [
                "TEST_SECURE",
                "CONTROL_INPUT_TEXT",
                "CONTROL_MOUSE_AND_KEYBOARD",
                "READ_INSTALLED_APPS",
                "READ_LGE_SDX",
                "READ_NOTIFICATIONS",
                "SEARCH",
                "WRITE_SETTINGS",
                "WRITE_NOTIFICATION_ALERT",
                "CONTROL_POWER",
                "READ_CURRENT_CHANNEL",
                "READ_RUNNING_APPS",
                "READ_UPDATE_INFO",
                "UPDATE_FROM_REMOTE_APP",
                "READ_LGE_TV_INPUT_EVENTS",
                "READ_TV_CURRENT_TIME"
              ],
              "serial": "2f930e2d2cfe083771f68e4fe7bb07"
            },
            "permissions": [
              "LAUNCH",
              "LAUNCH_WEBAPP",
              "APP_TO_APP",
              "CLOSE",
              "TEST_OPEN",
              "TEST_PROTECTED",
              "CONTROL_AUDIO",
              "CONTROL_DISPLAY",
              "CONTROL_INPUT_JOYSTICK",
              "CONTROL_INPUT_MEDIA_RECORDING",
              "CONTROL_INPUT_MEDIA_PLAYBACK",
              "CONTROL_INPUT_TV",
              "CONTROL_POWER",
              "READ_APP_STATUS",
              "READ_CURRENT_CHANNEL",
              "READ_INPUT_DEVICE_LIST",
              "READ_NETWORK_STATE",
              "READ_RUNNING_APPS",
              "READ_TV_CHANNEL_LIST",
              "WRITE_NOTIFICATION_TOAST",
              "READ_POWER_STATE",
              "READ_COUNTRY_INFO"
            ],
            "signatures": [
              {
                "signatureVersion": 1,
                "signature": "eyJhbGdvcml0aG0iOiJSU0EtU0hBMjU2Iiwia2V5SWQiOiJ0ZXN0LXNpZ25pbmctY2VydCIsInNpZ25hdHVyZVZlcnNpb24iOjF9.hrVRgjCwXVvE2OOSpDZ58hR+59aFNwYDyjQgKk3auukd7pcegmE2CzPCa0bJ0ZsRAcKkCTJrWo5iDzNhMBWRyaMOv5zWSrthlf7G128qvIlpMT0YNY+n/FaOHE73uLrS/g7swl3/qH/BGFG2Hu4RlL48eb3lLKqTt2xKHdCs6Cd4RMfJPYnzgvI4BNrFUKsjkcu+WD4OO2A27Pq1n50cMchmcaXadJhGrOqH5YmHdOCj5NSHzJYrsW0HPlpuAx/ECMeIZYDh6RMqaFM2DXzdKX9NmmyqzJ3o/0lkk/N97gfVRLW5hA29yeAwaCViZNCP8iC9aO0q9fQojoa7NQnAtw=="
              }
            ]
          }
        }}
        """
        var json = JSON(parseJSON: message)
        if let key = key {
            json["payload"]["client-key"].stringValue = key
        }

        sendMessage(json, { [weak self, uuid] in
            switch $0["type"].stringValue {
            case "registered":
                let key = $0["payload"]["client-key"].stringValue
                self?.key = key
                self?.storage["client-key-\(uuid)"] = key
                self?.registered()
                return true
            case "response":
                Log().debug($0["payload"]["pairingType"].stringValue)
                self?.registerStateChangedHandler?(.registration)
            default:
                assert(false, "Unexpected response")
            }
            return false
        })
    }

    private func setupInputWebSocket(path: String) {
        var request = URLRequest(url: URL(string: path)!)
        request.timeoutInterval = 5
        inputWebSocket = WebSocket(request: request, certPinner: FoundationSecurity(allowSelfSigned: true))
        inputWebSocket?.onEvent = {
            print("Input WebSocket", $0)
        }
        inputWebSocket?.connect()
    }

    private func registered() {
        registerStateChangedHandler?(.registered)
        subscribe(uri: "ssap://audio/getVolume") { [weak self] in
            self?.state.updateVolume(payload: $0["payload"])
        }

//        subscribe(uri: "ssap://audio/getAppState") { [weak self] in
//
//        }

        subscribe(uri: "ssap://com.webos.applicationManager/listApps") { (_) in

        }

        request(uri: "ssap://com.webos.service.networkinput/getPointerInputSocket") { [weak self] in
            guard let inputSocketPath = $0["payload"]["socketPath"].string else { return }
            self?.setupInputWebSocket(path: inputSocketPath)
        }


//        request(uri: "ssap://api/getServiceList", { _ in })
//        request(uri: "ssap://audio/getStatus", { _ in })
//        request(uri: "ssap://com.webos.applicationManager/getForegroundAppInfo", { _ in })

//        request(uri: "ssap://com.webos.applicationManager/listLaunchPoints", { _ in })
//        request(uri: "ssap://com.webos.service.appstatus/getAppStatus", { _ in })


//

//
//        audio/getStatus
//
//
//        audio/setVolume
//
//        Example: lgtv.request('ssap://audio/setVolume', {volume: 10});
//
//        audio/volumeUp
//
//        audio/volumeDown
//
//        com.webos.applicationManager/getForegroundAppInfo
//
//        com.webos.applicationManager/launch
//
//        com.webos.applicationManager/listLaunchPoints
//
//        com.webos.service.appstatus/getAppStatus
//
//        com.webos.service.ime/sendEnterKey
//
//        com.webos.service.ime/deleteCharacters
//
//        com.webos.service.tv.display/set3DOn
//
//        com.webos.service.tv.display/set3DOff
//
//        com.webos.service.update/getCurrentSWInformation
//
//        media.controls/play
//
//        Example: lgtv.request('ssap://media.controls/play');
//
//        media.controls/stop
//
//        media.controls/pause
//
//        Example: lgtv.request('ssap://media.controls/pause');
//
//        media.controls/rewind
//
//        media.controls/fastForward
//
//        media.viewer/close
//
//        system/turnOff
//
//        system.notifications/createToast
//
//        Show a Popup Window.
//
//        Example: lgtv.request('ssap://system.notifications/createToast', {message: 'Hello World!'});
//
//        system.launcher/close
//
//        system.launcher/getAppState
//
//        system.launcher/launch
//
//        Start an app.
//
//        Example: lgtv.request('ssap://system.launcher/launch', {id: 'netflix'});
//
//        system.launcher/open
//
//        tv/channelDown
//
//        tv/channelUp
//
//        tv/getChannelList
//
//        tv/getChannelProgramInfo
//
//        tv/getCurrentChannel
//
//        tv/getExternalInputList
//
//        tv/openChannel
//
//        tv/switchInput
//
//        webapp/closeWebApp

    }

    func setMute(_ mute: Bool) {
        request(uri: "ssap://audio/setMute", payload: ["mute": mute]) { (_) in

        }
    }


    func setVolume(_ volume: Int) {
        request(uri: "ssap://audio/setVolume", payload: ["volume": volume]) { (_) in
            print("Done", volume)
        }
    }

    func volumeDown() {
        request(uri: "ssap://audio/volumeDown") {
            print(#function, $0)
        }
    }

    func volumeUp() {
        request(uri: "ssap://audio/volumeUp") {
            print(#function, $0)
        }
    }

    func pause() {
        request(uri: "ssap://media.controls/pause") {
            print(#function, $0)
        }
    }

    func play() {
        request(uri: "ssap://media.controls/play") {
            print(#function, $0)
        }
    }
}

extension WebOSCommunicator {
    enum Button: String {
        case up = "UP"
        case down = "DOWN"
        case left = "LEFT"
        case right = "RIGHT"
        case enter = "ENTER"
        case home = "HOME"
        case back = "BACK"
    }

    func tapButton(_ button: Button) {
        let data = [("type", "button"),
                    ("name", button.rawValue)]
        write(data)
    }

    func move(_ x: Int, y: Int, drug: Bool = false) {
        guard x != 0 || y != 0 else { return }
        let data = [("type", "move"),
                    ("dx", "\(x)"),
                    ("dy", "\(y)"),
                    ("down", drug ? "1" : "0")]
        write(data)
    }

    func click() {
        let data = [("type", "click")]
        write(data)
    }

    func scroll(_ x: Float, y: Float, drug: Bool = false) {
        let data = [("type", "scroll"),
                    ("dx", "\(x)"),
                    ("dy", "\(y)")]
        write(data)
    }

    private func write(_ data: [(String, String)]) {
        let message = data.map({ "\($0):\($1)" }).joined(separator: "\n") + "\n\n"
        Log().debug("--Write Input--")
        Log().debug(message)
        inputWebSocket?.write(string: message)
    }
}

extension WebOSCommunicator {
    struct State {
        var maxVolume: Int = 0
        var volume: Int = 0
        var mute: Bool = false

        mutating func updateVolume(payload: JSON) {
            let payload = payload["volumeStatus"]
            maxVolume = payload["maxVolume"].intValue
            volume = payload["volume"].intValue
            mute = payload["muteStatus"].boolValue
        }
    }
}
