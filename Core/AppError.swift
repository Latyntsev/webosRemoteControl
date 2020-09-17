//
//  AppError.swift
//  RemoteControl
//
//  Created by Aleksandr Latyntsev on 7/30/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Foundation

enum AppError: Error {
    case cantGenerateURL
    case dataNotFound
    case cantConvertData
}
