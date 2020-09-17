//
//  ModelProtocol.swift
//  webosRemoteControl
//
//  Created by Aleksandr Latyntsev on 8/19/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol ModelProtocol: SimpleStorageObjectProtocol {
    var json: JSON { get }
    init(_ json: JSON)
}

extension ModelProtocol {
    init(fromData data: Data) {
        self.init(try! JSON(data: data))
    }

    func toData() -> Data {
        try! json.rawData()
    }
}

