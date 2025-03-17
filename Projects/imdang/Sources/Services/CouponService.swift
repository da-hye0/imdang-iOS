//
//  CouponService.swift
//  imdang
//
//  Created by daye on 2/7/25.
//

import Foundation
import NetworkKit
import RxSwift
import Alamofire

class CouponService {
    static let shared = CouponService()
    
    private var disposeBag = DisposeBag()
    private let networkManager = NetworkManager()
    
    func issueCoupons() -> Observable<Bool> {
        
        let endpoint = Endpoint<BasicResponse>(
            baseURL: .imdangAPI,
            path: "/coupons/issue",
            method: .post,
            headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)]
        )
        
        return networkManager.requestOptional(with: endpoint)
            .map { _ in
                print("쿠폰 발급 성공")
                return true
            }
            .catch { error in
                print("Error: \(error.localizedDescription)")
                return Observable.just(false)
            }
    }
    
    // @discardableResult 써서 ID는 리턴하게 하려했는데 생각대로 안됨
    func getCoupons() -> Observable<CouponsResponse> {
        let endpoint = Endpoint<CouponsResponse>(
            baseURL: .imdangAPI,
            path: "/my-coupons/detail",
            method: .get,
            headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)]
        )

        return networkManager.request(with: endpoint)
            .map { response in
                return response
            }
            .catch { error in
                print("Coupons request failed with error: \(error)")
                return Observable.empty()
            }
    }
    
}
