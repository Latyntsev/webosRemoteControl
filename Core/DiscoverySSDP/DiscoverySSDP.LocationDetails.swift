//
//  DiscoverySSDP.LocationDetails.swift
//  webosRemoteControl
//
//  Created by Aleksandr Latyntsev on 8/18/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Foundation
import SwiftyXMLParser

extension DiscoverySSDP {
    struct LocationDetails {
        let friendlyName: String
        let modelName: String
        let modelNumber: String
        let modelDescription: String
        let manufacturer: String
//        let deviceServices: [DeviceService]


        init(xml: XML.Accessor) throws {
            let device = xml["root", "device"]
            self.friendlyName = device["friendlyName"].text ?? ""
            self.modelName = device["modelName"].text ?? ""
            self.modelNumber = device["modelNumber"].text ?? ""
            self.modelDescription = device["modelDescription"].text ?? ""
            self.manufacturer = device["manufacturer"].text ?? ""
//            self.deviceServices = device["serviceList"]["service"].map({ DeviceService(xml: $0) })
        }
    }
}
