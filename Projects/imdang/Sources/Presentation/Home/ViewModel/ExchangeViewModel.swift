//
//  ExchangeViewModel.swift
//  imdang
//
//  Created by 임대진 on 2/2/25.
//

import Foundation
import NetworkKit
import Alamofire
import RxSwift

final class ExchangeViewModel {
    private var disposeBag = DisposeBag()
    private let networkManager = NetworkManager()
    
    func loadRequestedByMe(state: DetailExchangeState) -> Observable<[Insight]?> {
        return Observable.create { [self] observer in
            
            let parameters: [String: Any] = [
                "requestMemberId": UserdefaultKey.memberId,
                "exchangeRequestStatus": state.rawValue.uppercased(),
                "pageNumber": 0,
                "pageSize": 10,
                "direction": "ASC",
                "properties": [
                  "string"
                ]
            ]
            
            let endpoint = Endpoint<InsightResponse>(
                baseURL: .imdangAPI,
                path: "/my-exchanges/requested-by-me",
                method: .get,
                encodingType: .query,
                headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)],
                parameters: parameters
            )
            
            networkManager.request(with: endpoint)
                .subscribe(
                    onNext: { entity in
                        observer.onNext(entity.toEntitiy())
                        observer.onCompleted()
                    },
                    onError: { error in
                        print("Request failed with error: \(error)")
                        observer.onNext(nil)
                        observer.onCompleted()
                    }
                )
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    func loadRequestedByOthers(state: DetailExchangeState) -> Observable<[Insight]?> {
        return Observable.create { [self] observer in
            
            let parameters: [String: Any] = [
                "requestMemberId": UserdefaultKey.memberId,
                "exchangeRequestStatus": state.rawValue.uppercased(),
                "pageNumber": 0,
                "pageSize": 10,
                "direction": "DESC",
                "properties": [
                  "string"
                ]
            ]
            
            let endpoint = Endpoint<InsightResponse>(
                baseURL: .imdangAPI,
                path: "/my-exchanges/requested-by-others",
                method: .get,
                encodingType: .query,
                headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)],
                parameters: parameters
            )
            
            networkManager.request(with: endpoint)
                .subscribe(
                    onNext: { entity in
                        observer.onNext(entity.toEntitiy())
                        observer.onCompleted()
                    },
                    onError: { error in
                        print("Request failed with error: \(error)")
                        observer.onNext(nil)
                        observer.onCompleted()
                    }
                )
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}
