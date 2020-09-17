//
//  WebServiceResource.swift
//  RemoteControl
//
//  Created by Aleksandr Latyntsev on 7/30/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Foundation

struct WebServiceResource<Result> {
    enum Method: String {
        case get = "GET"
        case post = "POST"
        case subscribe = "SUBSCRIBE"
    }
    typealias Parser = (Data) throws -> Result
    let method: Method
    let url: URL
    let body: Data?
    let headers: [String: String]
    let parser: Parser

    init(method: Method, link: String, path: String? = nil, queryParams: [String: String]? = nil, headers: [String: String] = [:], body: BodyProtocol? = nil, parser: @escaping Parser) throws {
        guard var components = URLComponents(string: link) else { throw AppError.cantGenerateURL }
        if let path = path {
            components.path += path
        }
        if let queryParams = queryParams {
            components.queryItems = (components.queryItems ?? []) + queryParams.map({ URLQueryItem(name: $0.key, value: $0.value) })
        }
        guard let url = components.url else { throw AppError.cantGenerateURL }
        self.url = url
        self.method = method
        self.body = try body?.generateBody()
        self.headers = headers
        self.parser = parser
    }

    func toRequest() -> URLRequest {
        var request = URLRequest(url: url)
        request.httpBody = body
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        return request
    }
}
