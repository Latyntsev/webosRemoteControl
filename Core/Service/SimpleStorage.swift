//
//  SimpleStorage.swift
//  webosRemoteControl
//
//  Created by Aleksandr Latyntsev on 8/19/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Foundation
import SwiftyJSON

class SimpleStorage {
    static let shared = SimpleStorage()
    let storage: UserDefaults
    init(_ name: String? = nil) {
        if let name = name {
            storage = UserDefaults(suiteName: name) ?? .standard
        } else {
            storage = .standard
        }
    }

    subscript(_ name: String) -> Data? {
        get { storage.data(forKey: name) }
        set { storage.set(newValue, forKey: name) }
    }

    subscript(_ name: String) -> String? {
        get { storage.string(forKey: name) }
        set { storage.set(newValue, forKey: name) }
    }

    subscript(_ name: String) -> Int? {
        get { storage.integer(forKey: name) }
        set { storage.set(newValue, forKey: name) }
    }

    subscript(_ name: String) -> JSON? {
        get {
            guard let data = self[name] as Data? else { return nil }
            do {
                return try JSON(data: data)
            } catch {
                Log().error(error)
                assert(false, error.localizedDescription)
                return nil
            }
        }
        set {
            do {
                self[name] = try newValue?.rawData()
            } catch {
                Log().error(error)
                assert(false, error.localizedDescription)
            }

        }
    }

    subscript<T: SimpleStorageObjectProtocol>(_ name: String) -> T? {
        get {
            guard let data = self[name] as Data? else { return nil }
            return T(fromData: data)
        }
        set {
            self[name] = newValue?.toData()
        }
    }
}

protocol SimpleStorageObjectProtocol {
    init(fromData data: Data)
    func toData() -> Data
}

extension SimpleStorage {
    var mainService: ServiceProxyModel? {
        get { self[#function] }
        set { self[#function] = newValue }
    }
}
