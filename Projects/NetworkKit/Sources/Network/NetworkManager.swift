//
//  NetworkManager.swift
//  NetworkKit
//
//  Created by 임대진 on 11/25/24.
//

import Foundation
import RxSwift
public import Alamofire

public struct BasicResponse: Codable {
    let code: String
    let message: String
}

public final class NetworkManager: Network {
//    public var session = Session(interceptor: AuthInterceptor(), eventMonitors: [APIEventMonitor()])
//    
//    public init()  {
////        self.session = session
//    }
    var session: Session
    
    public init(session: Session = Session(eventMonitors: [APIEventMonitor()])) {
        self.session = session
    }
    
    public func request<E: Requestable>(with endpoint: E) -> Observable<E.Response> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "Network Error", code: -1, userInfo: nil))
                return Disposables.create()
            }
            
            let request = self.session.request(endpoint.makeURL(),
                                               method: endpoint.method,
                                               parameters: endpoint.parameters,
                                               encoding: endpoint.encoding,
                                               headers: endpoint.headers)
                .validate()
                .responseDecodable(of: E.Response.self) { response in
                    switch response.result {
                    case .success(let data):
                        observer.onNext(data)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    public func requestOptional<E: Requestable>(with endpoint: E) -> Observable<E.Response?> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "Network Error", code: -1, userInfo: nil))
                return Disposables.create()
            }
            
            let request = self.session.request(endpoint.makeURL(),
                                               method: endpoint.method,
                                               parameters: endpoint.parameters,
                                               encoding: endpoint.encoding,
                                               headers: endpoint.headers)
                .validate()
                .response { response in
                    if (200..<300).contains(response.response?.statusCode ?? 0) {
                        
                        if let data = response.data, !data.isEmpty {
                            do {
                                let decodedData = try JSONDecoder().decode(E.Response.self, from: data)
                                print("""
                                📲 NETWORK Response LOG
                                📲 StatusCode: \(response.response?.statusCode ?? 0)
                                📲 Data: \(response.data?.toPrettyPrintedString ?? "")
                                """)
                                observer.onNext(decodedData)
                                observer.onCompleted()
                            } catch {
                                observer.onError(error)
                            }
                        } else {
                            observer.onNext(nil)
                            observer.onCompleted()
                        }
                    } else {
                        if let errorData = response.data {
                            do {
                                let decodedError = try JSONDecoder().decode(BasicResponse.self, from: errorData)
                                print("❌ 에러 메세지: \(decodedError.message)")
                                observer.onError(NSError(domain: decodedError.message, code: response.response?.statusCode ?? -1, userInfo: ["data": decodedError]))
                            } catch {
                                print("❌ decodedError: \(error)")
                                observer.onError(error)
                            }
                        } else {
                            observer.onError(NSError(domain: "Network Error", code: response.response?.statusCode ?? -1, userInfo: nil))
                        }
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
