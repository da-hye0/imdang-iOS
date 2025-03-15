//
//  AuthInterceptor.swift
//  NetworkKit
//
//  Created by 임대진 on 2/17/25.
//

import Foundation
public import Alamofire

public final class AuthInterceptor: RequestInterceptor {
    private let tokenManager = TokenManager()
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        Task {
            var request = urlRequest
            if let accessToken = await tokenManager.getAccessToken() {
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            completion(.success(request))
        }
    }
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        Task {
            let success: () = await tokenManager.refreshToken() { re in
                completion(re ? .retry : .doNotRetry)
            }
        }
    }
}


public actor TokenManager {
    private var accessToken: String?
    
    public func getAccessToken() -> String? {
        return accessToken
    }
    
    public func refreshToken(completion: @escaping (Bool) -> Void) {
        Task {
            let newToken = "new_access_token"
            self.accessToken = newToken
            completion(true)
        }
    }
}
