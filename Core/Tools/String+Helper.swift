//
//  String+Helper.swift
//  RemoteControl
//
//  Created by Aleksandr Latyntsev on 8/1/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Foundation

extension String {
    func trim(_ characters: String = "\r\n ") -> String {
        trimmingCharacters(in: .init(charactersIn: characters))
    }
}
