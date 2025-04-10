//
//  Requestable.swift
//  NetworkKit
//
//  Created by 임대진 on 11/25/24.
//

import UIKit

public import Alamofire

public typealias HTTPRequestParameter = [String: Any]

public enum EncodingType {
    case body, query
}

public protocol Requestable {
    
    associatedtype Response: Decodable
    
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var encodingType: EncodingType? { get } 
    var headers: HTTPHeaders { get }
    var parameters: HTTPRequestParameter? { get }
    var encoding: ParameterEncoding { get }
    
    func makeURL() -> String
}

public protocol MultipartRequestable: Requestable {
    var images: [UIImage] { get }
    var jsonData: Data { get }
    var isCreate: Bool { get }
}

public extension Requestable {
    
    var encoding: ParameterEncoding {
        if let encodingType = encodingType {
            switch encodingType {
            case .body:
                return JSONEncoding.default
            case .query:
                return URLEncoding.default
            }
        } else {
            switch method {
            case .post, .put:
                return JSONEncoding.default
            default:
                return URLEncoding.default
            }
        }
    }
    
    func makeURL() -> String {
        return "\(baseURL)\(path)"
    }
}
