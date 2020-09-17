//
//  WebService.swift
//  RemoteControl
//
//  Created by Aleksandr Latyntsev on 7/30/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Foundation
import PromiseKit

class WebService {
    static var shared = WebService()
    let session = URLSession.shared

    func execute<T>(resource: WebServiceResource<T>) -> Promise<T> {
        let pending = Promise<T>.pending()
        let request = resource.toRequest()
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                pending.resolver.reject(error)
                return
            }
            guard let data = data else {
                pending.resolver.reject(AppError.dataNotFound)
                return
            }
            do {
                let result = try resource.parser(data)
                pending.resolver.fulfill(result)
            } catch {
                pending.resolver.reject(error)
            }

        }
        task.resume()
        return pending.promise
    }
}


extension WebService {
    func loadSSDPServiceInfo(resource: WebServiceResource<DiscoverySSDP.LocationDetails>) -> Promise<DiscoverySSDP.LocationDetails> {
        return execute(resource: resource)
    }
}
