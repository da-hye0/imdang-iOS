//
//  Endpoint.swift
//  NetworkKit
//
//  Created by 임대진 on 11/25/24.
//

import UIKit

public import Alamofire

public struct Endpoint<R>: Requestable where R: Decodable {
    
    public typealias Response = R
    
    public let baseURL: String
    public let path: String
    public let method: HTTPMethod
    public let encodingType: EncodingType?
    public let headers: HTTPHeaders
    public let parameters: HTTPRequestParameter?
    
    
    public init(
        baseURL: BaseURL,
        path: String,
        method: HTTPMethod,
        encodingType: EncodingType? = nil,
        headers: HTTPHeaders = [HTTPHeader(name: "Content-Type", value: "application/json")],
        parameters: HTTPRequestParameter? = nil
    ) {
        self.headers = headers
        self.baseURL = baseURL.configValue
        self.path = path
        self.method = method
        self.encodingType = encodingType
        self.parameters = parameters
    }
}

public struct MultipartEndpoint<R>: MultipartRequestable where R: Decodable {
    
    public typealias Response = R
    
    public let baseURL: String
    public let path: String
    public let method: HTTPMethod
    public let encodingType: EncodingType?
    public let headers: HTTPHeaders
    public let parameters: HTTPRequestParameter?
    
    public var images: [UIImage]
    public var jsonData: Data
    public var isCreate: Bool
    
    
    public init(
        baseURL: BaseURL,
        path: String,
        method: HTTPMethod,
        encodingType: EncodingType? = nil,
        headers: HTTPHeaders = [HTTPHeader(name: "Content-Type", value: "application/json")],
        parameters: HTTPRequestParameter? = nil,
        images: [UIImage],
        jsonData: Data,
        isCreate: Bool
    ) {
        self.headers = headers
        self.baseURL = baseURL.configValue
        self.path = path
        self.method = method
        self.encodingType = encodingType
        self.parameters = parameters
        self.images = images
        self.jsonData = jsonData
        self.isCreate = isCreate
    }
}

