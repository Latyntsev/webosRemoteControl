//
//  DiscoverySSDP.Service.swift
//  webosRemoteControl
//
//  Created by Aleksandr Latyntsev on 8/18/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Foundation
import Socket
import PromiseKit

extension DiscoverySSDP {
    class Service {
        let address: Socket.Address
        let host: String
        let port: Int32 = 3000
        let uuid: String
        let location: String
        private(set) var locationDetails: LocationDetails?
        private(set) var infoLoaded = false

        init?(datagram: UDPDatagram, address: Socket.Address) {
            guard let usn = datagram.headers["USN"] else { return nil }
            guard let uuidRange = usn.range(of: "uuid:[\\d\\w-]*", options: .regularExpression) else { return nil }
            self.uuid = String(usn[uuidRange]).components(separatedBy: ":")[1]
            self.address = address

            guard let location = datagram.headers["Location"] else { return nil }
            guard let host = URLComponents(string: location)?.host else { return nil }
            self.host = host
            self.location = location
        }

        func loadInfo() -> Promise<Void> {
            return Promise<Void>()
                .map({ try self.locationResource() })
                .then({ WebService.shared.loadSSDPServiceInfo(resource: $0) })
                .done({ self.locationDetails = $0 })
                .done({ self.infoLoaded = true })

        }

//        func subscribe() {
//            guard let resources = try? self.subscribeEventsResource() else { return }
//            for resource in resources {
//                WebService.shared.execute(resource: resource) { result in
//                    DispatchQueue.main.async {
//                        print("Subscribed", result)
//                    }
//                }
//            }
//        }
    }
}

// MARK: - Resources
extension DiscoverySSDP.Service {
    func locationResource() throws -> WebServiceResource<DiscoverySSDP.LocationDetails> {
        try WebServiceResource(method: .get, link: location) {
            try DiscoverySSDP.LocationDetails(xml: $0.toXML())
        }
    }

//    func subscribeEventsResource() throws -> [WebServiceResource<Void>] {
//        guard let ip = getIPAddress() else { throw AppError.cantGenerateURL }
//        guard let deviceServices = locationDetails?.deviceServices else { throw AppError.cantGenerateURL }
//
//        return try deviceServices
//            .map({ ds -> String in
//                let path = ds.eventSubURL.trim("/")
//                guard !path.isEmpty else { throw AppError.cantGenerateURL }
//                return path
//            })
//            .map({ path -> WebServiceResource<Void> in
//                let headers = ["TIMEOUT": "Second-300",
//                               "CALLBACK": "<http://\(ip):1986/\(path)>",
//                               "NT": "upnp:event",
//                               "User-Agent": "iOS UPnP/1.1 ConnectSDK"]
//                return try WebServiceResource(method: .subscribe, link: location, path: path, headers: headers) { _ in return () }
//            })
//    }
}
