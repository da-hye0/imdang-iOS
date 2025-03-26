//
//  StoregeBoxViewModel.swift
//  imdang
//
//  Created by 임대진 on 2/2/25.
//

import Foundation
import NetworkKit
import Alamofire
import RxSwift

struct AptComplexByDistrict: Codable {
    let apartmentComplexName: String
    let insightCount: Int
}

final class StorageBoxViewModel {
    var totalCount = 0
    var totalPage = 0
    var isLoading: Bool = false
    private var disposeBag = DisposeBag()
    private let networkManager = NetworkManager()
    
    // 단지별보기 모달 데이터
    func loadMyComplexes(address: AddressResponse) -> Observable<[AptComplexByDistrict]?> {
        let parameters: [String: Any] = [
            "siDo": address.siDo,
            "siGunGu": address.siGunGu,
            "eupMyeonDong": address.eupMyeonDong
        ]
        
        let endpoint = Endpoint<[AptComplexByDistrict]>(
            baseURL: .imdangAPI,
            path: "/my-insights/by-district/apartment-complexes",
            method: .get,
            headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: parameters
        )
        
        return networkManager.requestOptional(with: endpoint)
            .map { data in
                return data
            }
            .catch { error in
                print("Error: \(error.localizedDescription)")
                return Observable.just(nil)
            }
    }
    
    // 보관함 주소 박스 데이터
    func loadMyDistricts() -> Observable<[AddressResponse]?> {
        let endpoint = Endpoint<[AddressResponse]>(
            baseURL: .imdangAPI,
            path: "/my-insights/districts",
            method: .get,
            headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)]
        )
        
        return networkManager.request(with: endpoint)
            .map { data in
                return data.filter { $0.eupMyeonDong != ""}
            }
            .catch { error in
                print("Error: \(error.localizedDescription)")
                return Observable.just(nil)
            }
    }
    
    
    func loadStoregeInsights(address: AddressResponse, pageIndex: Int, apartmentComplexName: String? = nil, onlyMine: Bool = false) -> Observable<[Insight]?> {
        var parameters: [String: Any] = [
            "siDo": address.siDo,
            "siGunGu": address.siGunGu,
            "eupMyeonDong": address.eupMyeonDong,
            "onlyMine" : onlyMine,
            "pageNumber" : pageIndex,
            "pageSize" : 100,
            "direction" : "DESC",
            "properties" : [],
        ]
        if let aptName = apartmentComplexName {
            parameters["apartmentComplexName"] = aptName
        }
        
        let endpoint = Endpoint<StorageResponse>(
            baseURL: .imdangAPI,
            path: "/my-insights",
            method: .get,
            encodingType: .query,
            headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: parameters
        )
        
        return networkManager.request(with: endpoint)
            .map { data in
                self.totalCount = data.totalElements
                self.totalPage = data.totalPages
                return data.toEntitiy()
            }
            .catch { error in
                print("Error: \(error.localizedDescription)")
                return Observable.just(nil)
            }
    }
    
    func loadInsightDetail(id: String) -> Observable<InsightDetail?> {
        let parameters: [String: Any] = [
            "insightId": id
        ]
        
        let endpoint = Endpoint<InsightDetailResponse>(
            baseURL: .imdangAPI,
            path: "/insights/detail",
            method: .get,
            headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: parameters
        )
        
        return networkManager.request(with: endpoint)
            .map { data in
                return data.toDetail()
            }
            .catch { error in
                print("Error: \(error.localizedDescription)")
                return Observable.just(nil)
            }
    }
}
