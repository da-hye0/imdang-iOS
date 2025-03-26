//
//  APIEventMonitor.swift
//  NetworkKit
//
//  Created by 임대진 on 11/25/24.
//

import UIKit

public import Alamofire

public final class APIEventMonitor: EventMonitor {

    public let queue = DispatchQueue(label: "APIEventMonitor")
    
    public init() { }

    public func requestDidFinish(_ request: Request) {
        
        print("""
        📱 NETWORK Reqeust LOG
        📱 URL: \(request.request?.url?.absoluteString ?? "")
        📱 Method: \(request.request?.httpMethod ?? "")
        📱 Headers: \(request.request?.allHTTPHeaderFields ?? [:])
        📱 Body: \(request.request?.httpBody?.toPrettyPrintedString ?? "")

        ------------------------------------------------------------------------
        """)
    }

    public func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        
        print("""
        📲 NETWORK Response LOG
        📲 URL: \(request.request?.url?.absoluteString ?? "")
        📲 Result: \(response.result)
        📲 StatusCode: \(response.response?.statusCode ?? 0)
        📲 Data: \(response.data?.toPrettyPrintedString ?? "")

        """)
        if response.response?.statusCode ?? 0 >= 300, let prettyPrintedData = response.data?.toPrettyPrintedString, !prettyPrintedData.contains("J003") {
            DispatchQueue.main.async {
                self.showAlert(code: response.response?.statusCode ?? 0, message: prettyPrintedData)
            }
        }
    }
    
    private func showAlert(code: Int, message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return
        }
        
        let alertController = UIAlertController(title: "Network \(code) Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let rootViewController = windowScene.windows.first?.rootViewController {
            if let presentedViewController = rootViewController.presentedViewController {
                presentedViewController.dismiss(animated: false) {
                    rootViewController.present(alertController, animated: true, completion: nil)
                }
            } else {
                rootViewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

public final class APIDebugEventMonitor: EventMonitor {

    public let queue = DispatchQueue(label: "APIDebugEventMonitor")
    
    public init() { }
    
    public func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        if response.response?.statusCode ?? 0 >= 300, let prettyPrintedData = response.data?.toPrettyPrintedString, !prettyPrintedData.contains("J003") {
            DispatchQueue.main.async {
                self.showAlert(code: response.response?.statusCode ?? 0, message: prettyPrintedData)
            }
        }
    }
    
    private func showAlert(code: Int, message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return
        }
        
        let alertController = UIAlertController(title: "Network \(code) Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let rootViewController = windowScene.windows.first?.rootViewController {
            if let presentedViewController = rootViewController.presentedViewController {
                presentedViewController.dismiss(animated: false) {
                    rootViewController.present(alertController, animated: true, completion: nil)
                }
            } else {
                rootViewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

extension Data {
    
    public var toPrettyPrintedString: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        return prettyPrintedString as String
    }
    
    public func dataToString() -> String {
        return String(data: self, encoding: .utf8) ?? ""
    }
}
