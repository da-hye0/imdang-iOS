//
//  NetworkManager.swift
//  NetworkKit
//
//  Created by 임대진 on 11/25/24.
//

import Foundation
import RxSwift
public import Alamofire

public final class NetworkManager: Network {
//    public var session = Session(interceptor: AuthInterceptor(), eventMonitors: [APIEventMonitor()])
//    
//    public init()  {
////        self.session = session
//    }
    var session: Session
    
    #if DEBUG
    public init(session: Session = Session(eventMonitors: [APIEventMonitor()])) {
        self.session = session // 모든 로그 확인용
    }
    #else
    public init(session: Session = Session(eventMonitors: [APIDebugEventMonitor()])) {
        self.session = session // 에러시 알럿창 띄우기용
    }
    #endif
    
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
                .responseDecodable(of: E.Response.self) { response in
                    switch response.result {
                    case .success(let data):
                        observer.onNext(data)
                        observer.onCompleted()
                    case .failure(let error):
                        if (200..<300).contains(response.response?.statusCode ?? 0) {
                            observer.onNext(nil)
                            observer.onCompleted()
                        } else {
                            observer.onError(error)
                        }
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    public func upload<E: MultipartRequestable>(with endpoint: E) -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "Network Error", code: -1, userInfo: nil))
                return Disposables.create()
            }
            
            let request = self.session.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(endpoint.jsonData, withName: endpoint.isCreate ? "createInsightCommand" : "updateInsightCommand", mimeType: "application/json")
                
                for (index, image) in endpoint.images.enumerated() {
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                        multipartFormData.append(imageData, withName: "mainImage", fileName: "image_\(index).jpeg", mimeType: "image/jpeg")
                    }
                }
            }, to: endpoint.makeURL(), method: endpoint.method, headers: endpoint.headers)
            .validate()
            .responseDecodable(of: E.Response.self) { response in
                switch response.result {
                case .success(let data):
                    observer.onNext(true)
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
}
