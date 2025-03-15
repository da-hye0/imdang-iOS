//
//  BaseURL.swift
//  NetworkKit
//
//  Created by 임대진 on 11/25/24.
//

import Foundation

internal import Alamofire

public enum BaseURL: String {
    case imdangAPI = "IMDANG_API"
    
    var configValue: String {
        if let infoDictionary: [String: Any] = Bundle.main.infoDictionary,
           let baseURL = infoDictionary[self.rawValue] as? String {
            return baseURL.decodeURL()
        } else {
            return "http://imdang.info"
        }
    }
}

extension String {
    func decodeURL() -> String {
        var urlDecodedString = self.removingPercentEncoding ?? .init()
        
        if urlDecodedString == "" {
            urlDecodedString = self
            urlDecodedString = urlDecodedString.replacingOccurrences(of: "%3A%2F%2F", with: "://")
            urlDecodedString = urlDecodedString.replacingOccurrences(of: "%26", with: "&")
            urlDecodedString = urlDecodedString.replacingOccurrences(of: "%2F", with: "/")
            urlDecodedString = urlDecodedString.replacingOccurrences(of: "%3A", with: ":")
            urlDecodedString = urlDecodedString.replacingOccurrences(of: "%3F", with: "?")
            urlDecodedString = urlDecodedString.replacingOccurrences(of: "%3D", with: "=")
        }
        
        return urlDecodedString
    }
}
