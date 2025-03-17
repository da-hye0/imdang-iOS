//
//  InsightDetailViewModel.swift
//  SharedLibraries
//
//  Created by 임대진 on 2/1/25.
//

import UIKit
import NetworkKit
import RxSwift
import Alamofire

enum RecommendResult {
    case success
    case failure
    case recommended
    case beforeExchange
}

struct ExchangeResponse: Codable {
    let exchangeRequestId: String
}

struct InsightIDResponse: Codable {
    let insightId: String
}

final class InsightDetailViewModel {
    private var disposeBag = DisposeBag()
    private let networkManager = NetworkManager()
    
    func requestInsight(thisInsightId: String, myInsightId: String? = nil, couponId: String? = nil) -> Observable<Bool> {
        var parameters: [String: Any] = [
            "requestedInsightId": thisInsightId,
            "requestMemberId": UserdefaultKey.memberId
        ]
        if let myInsightId = myInsightId {
            parameters["requestMemberInsightId"] = myInsightId
        }
        
        if let couponId = couponId {
            parameters["memberCouponId"] = couponId
        }
        
        let endpoint = Endpoint<ExchangeResponse>(
            baseURL: .imdangAPI,
            path: "/exchanges/request",
            method: .post,
            headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: parameters
        )
        
        return networkManager.request(with: endpoint)
            .map { _ in
                return true
            }
            .catch { error in
                print("Error: \(error.localizedDescription)")
                return Observable.just(false)
            }
    }
    
    func acceptInsight(exchangeRequestId: String) -> Observable<Bool> {
        let parameters: [String: Any] = [
            "exchangeRequestId": exchangeRequestId,
            "requestedMemberId": UserdefaultKey.memberId
        ]
        
        let endpoint = Endpoint<ExchangeResponse>(
            baseURL: .imdangAPI,
            path: "/exchanges/accept",
            method: .post,
            headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: parameters
        )
        
        return networkManager.request(with: endpoint)
            .map { _ in
                return true
            }
            .catch { error in
                print("Error: \(error.localizedDescription)")
                return Observable.just(false)
            }
    }
    
    func rejecttInsight(exchangeRequestId: String) -> Observable<Bool> {
        let parameters: [String: Any] = [
            "exchangeRequestId": exchangeRequestId,
            "requestedMemberId": UserdefaultKey.memberId
        ]
        
        let endpoint = Endpoint<ExchangeResponse>(
            baseURL: .imdangAPI,
            path: "/exchanges/reject",
            method: .post,
            headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: parameters
        )
        
        return networkManager.request(with: endpoint)
            .map { _ in
                return true
            }
            .catch { error in
                print("Error: \(error.localizedDescription)")
                return Observable.just(false)
            }
    }
    
    func recommendInsight(insightId: String) -> Observable<RecommendResult> {
        let parameters: [String: Any] = [
            "insightId": insightId,
            "recommendMemberId": UserdefaultKey.memberId
        ]
        
        let endpoint = Endpoint<InsightIDResponse>(
            baseURL: .imdangAPI,
            path: "/insights/recommend",
            method: .post,
            headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: parameters
        )
        
        return networkManager.requestOptional(with: endpoint)
            .map { _ in
                return .success
            }
            .catch { error in
                if let nsError = error as NSError? {
                    if nsError.domain == "ALREADY_RECOMMENDED" {
                        return Observable.just(.recommended)
                    } else if nsError.domain == "EXCHANGE_REQUIRED" {
                        return Observable.just(.beforeExchange)
                    } else {
                        return Observable.just(.failure)
                    }
                }
                return Observable.just(.failure)
            }
    }
    
    func accueInsight(insightId: String) -> Observable<Bool> {
        let parameters: [String: Any] = [
            "insightId": insightId,
            "accuseMemberId": UserdefaultKey.memberId
        ]
        
        let endpoint = Endpoint<InsightIDResponse>(
            baseURL: .imdangAPI,
            path: "/insights/accuse",
            method: .post,
            headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: parameters
        )
        
        return networkManager.request(with: endpoint)
            .map { _ in
                return true
            }
            .catch { error in
                print("Error: \(error.localizedDescription)")
                return Observable.just(false)
            }
    }
    
    func loadMyInsights() -> Observable<[Insight]?> {
        let parameters: [String: Any] = [
            "pageNumber": 0,
            "pageSize": 100,
            "direction": "ASC",
            "properties": [ "created_at" ]
        ]
        
        let endpoint = Endpoint<MyInsightResponse>(
            baseURL: .imdangAPI,
            path: "/my-insights/created-by-me",
            method: .get,
            headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: parameters
        )
        
        return networkManager.request(with: endpoint)
            .map { data in
                return data.toEntitiy()
            }
            .catch { error in
                print("Error: \(error.localizedDescription)")
                return Observable.just(nil)
            }
    }
}


