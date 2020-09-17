//
//  ServiceProxyModel.swift
//  webosRemoteControl
//
//  Created by Aleksandr Latyntsev on 8/19/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ServiceProxyModel: ModelProtocol {
    let name: String?
    let host: String
    let uuid: String

    init(name: String?, host: String, uuid: String) {
        self.name = name
        self.host = host
        self.uuid = uuid
    }

    init(_ json: JSON) {
        name = json["name"].string
        host = json["host"].stringValue
        uuid = json["uuid"].stringValue
    }

    var json: JSON {
        var data = [String: Any]()
        data["name"] = name
        data["host"] = host
        data["uuid"] = uuid
        return JSON(data)
    }
}
