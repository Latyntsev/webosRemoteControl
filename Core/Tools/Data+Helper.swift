//
//  Data+Helper.swift
//  RemoteControl
//
//  Created by Aleksandr Latyntsev on 7/30/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Foundation
import SwiftyXMLParser

extension Data {
    func toString(encoding: String.Encoding = .utf8) throws -> String {
        guard let result = String(data: self, encoding: encoding) else { throw AppError.cantConvertData }
        return result
    }

    func toXML() -> XML.Accessor {
        return XML.parse(self)
    }
}
