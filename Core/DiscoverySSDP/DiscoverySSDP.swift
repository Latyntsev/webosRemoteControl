//
//  DiscoverySSDP.swift
//  webosRemoteControl
//
//  Created by Aleksandr Latyntsev on 8/18/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Foundation
import Socket

class DiscoverySSDP {
    let host = "239.255.255.250"
    let port: Int32 = 1900
    let mSearchDelay: UInt32 = 5 // seconds
    let socket = try! Socket.create(family: .inet, type: .datagram, proto: .udp)
    private(set) var services: [Service] = []
    var serviceHandler: (([Service]) -> Void)? = nil
    private var active = false

    func start() {
        active = true
        startListener()
        startMSearch()
    }

    func stop() {
        active = false
    }

    var userAgent: String {
        let os = "macos"
        let osVersion = "10.4"
        let app = "RemoteControl"
        let appVersion = "0.0.1"
        return "\(os)/\(osVersion) UPnP/1.1 \(app)/\(appVersion)"
    }

    var hostHeader: String { "\(host):\(port)" }

    private func startListener() {
        DispatchQueue.global().async {
            repeat {
                var data = Data()
                let result = try? self.socket.readDatagram(into: &data)
                let string = String(data: data, encoding: .ascii) ?? ""
                let datagram = UDPDatagram(receivedData: string)
                guard let address = result?.address else { return }
                DispatchQueue.main.async {
                    self.receivedDatagram(datagram, address: address)
                }

            } while true && self.active
        }
    }

    private func mSearchDatagram() -> UDPDatagram {
        var datagram = UDPDatagram(method: "M-SEARCH")
        datagram.headers["Host"] = hostHeader
        datagram.headers["User-Agent"] = userAgent
//        datagram.headers["ST"] = "urn:lge-com:service:webos-second-screen:1"
//        datagram.headers["ST"] = "upnp:rootdevice"
        datagram.headers["ST"] = "urn:schemas-upnp-org:device:MediaRenderer:1"
        datagram.headers["MAN"] = "\"ssdp:discover\""
        datagram.headers["MX"] = "\(mSearchDelay)"
        return datagram
    }

    private func startMSearch() {
        var counter = 500
        DispatchQueue.global().async {
            repeat {
                self.sendDatagram(self.mSearchDatagram())
                usleep(self.mSearchDelay * 1000000)
                counter -= 1
            } while counter > 0 && self.active
        }
    }

    private func receivedDatagram(_ datagram: UDPDatagram, address: Socket.Address) {
        Log().debug("--receivedDatagram--")
        Log().debug(datagram.toString())
        guard let service = Service(datagram: datagram, address: address) else { return }
        guard !services.contains(where: { $0.uuid == service.uuid }) else { return }
        services.append(service)
        service.loadInfo()
            .done(on: .main, { self.serviceHandler?(self.services.filter({ $0.infoLoaded })) })
            .catch({ Log().error($0) })


    }

    private func sendDatagram(_ datagram: UDPDatagram) {
        let string = datagram.toString()
        guard let address = Socket.createAddress(for: host, on: port) else {
            assert(false, "Can't create address: \(host):\(port)")
            return
        }
        do {
            try socket.write(from: string, to: address)
            print("--Sent--")
//            print(string)
        } catch {
            assert(false, "Can't send message \n\n\(datagram)\n\n\(error.localizedDescription)")
        }
    }
}
