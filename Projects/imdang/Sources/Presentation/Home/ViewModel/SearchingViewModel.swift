//
//  SearchingViewModel.swift
//  imdang
//
//  Created by 임대진 on 1/24/25.
//

import Foundation
import NetworkKit
import Alamofire
import RxSwift

final class SearchingViewModel {
    var isLoading = false
    var totalElements: Int?
    private var disposeBag = DisposeBag()
    private let networkManager = NetworkManager()
    
    func loadMyvisited() -> Observable<[String]?> {
        let endpoint = Endpoint<[ApartmentComplexResponse]>(
            baseURL: .imdangAPI,
            path: "/insights/created-by-me/apartment-complexes",
            method: .get,
            headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)]
        )
        
        return networkManager.request(with: endpoint)
            .map { data in
                return data.map { $0.name }
            }
            .catch { error in
                print("Error: \(error.localizedDescription)")
                return Observable.just(nil)
            }
    }
    
    /// 아파트 단지별 인사이트 목록 조회
    func loadInsightsByApartment(page: Int, aptName: String) -> Observable<[Insight]?> {
        let parameters: [String: Any] = [
            "apartmentComplexName": aptName,
            "pageNumber": 0,
            "pageSize": 10 * (page + 1),
            "direction": "DESC",
            "properties": [ "created_at" ]
        ]
        
        let endpoint = Endpoint<InsightResponse>(
            baseURL: .imdangAPI,
            path: "/insights/by-apartment-complex",
            method: .get,
            headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: parameters
        )
        
        return networkManager.request(with: endpoint)
            .map { data in
                self.totalElements = data.totalElements
                return data.toEntitiy()
            }
            .catch { error in
                print("Error: \(error.localizedDescription)")
                return Observable.just(nil)
            }
    }
    
    func loadInsights(page: Int, type: FullInsightType, address: AddressResponse? = nil) -> Observable<[Insight]?> {
        let parameters: [String: Any] = [
            "pageNumber": 0,
            "pageSize": 10 * (page + 1),
            "direction": "ASC",
            "properties": [ "created_at" ]
        ]
        
        switch type {
        case .my:
            return Observable.just(nil)
        case .today:
            let endpoint = Endpoint<InsightResponse>(
                baseURL: .imdangAPI,
                path: "/insights/by-date",
                method: .get,
                headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)],
                parameters: parameters
            )
            
            return networkManager.request(with: endpoint)
                .map { data in
                    self.totalElements = data.totalElements
                    return data.toEntitiy()
                }
                .catch { error in
                    print("Error: \(error.localizedDescription)")
                    return Observable.just(nil)
                }
        case .search:
            if let address {
                let parameters: [String: Any] = [
                    "siGunGu": address.siGunGu,
                    "eupMyeonDong": address.eupMyeonDong,
                    "pageNumber" : 0,
                    "pageSize" : 10 * (page + 1),
                    "direction" : "DESC",
                    "properties" : [],
                ]
                
                let endpoint = Endpoint<InsightResponse>(
                    baseURL: .imdangAPI,
                    path: "/insights/by-district",
                    method: .get,
                    encodingType: .query,
                    headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)],
                    parameters: parameters
                )
                
                return networkManager.request(with: endpoint)
                    .map { data in
                        self.totalElements = data.totalElements
                        return data.toEntitiy()
                    }
                    .catch { error in
                        print("Error: \(error.localizedDescription)")
                        return Observable.just(nil)
                    }
            } else {
                return Observable.just(nil)
            }
        case .topTen:
            let parameters: [String: Any] = [
                "pageNumber": 0,
                "pageSize": 10
            ]
            let endpoint = Endpoint<InsightResponse>(
                baseURL: .imdangAPI,
                path: "/insights",
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
    
    func loadDistricts() -> Observable<[String]?> {
        let parameters: [String: Any] = ["pageSize": 100]
        
        let endpoint = Endpoint<DistrictsResponse>(
            baseURL: .imdangAPI,
            path: "/districts/si-gun-gu",
            method: .get,
            headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: parameters
        )
        
        return networkManager.request(with: endpoint)
            .map { data in
                return data.toAddresses().map { $0.siGunGu }
            }
            .catch { error in
                print("Error: \(error.localizedDescription)")
                return Observable.just(nil)
            }
    }
    
    func loadDongAddresses(siGunGu: String) -> Observable<[String: [String]]?> {
        let parameters: [String: Any] = ["siGunGu": siGunGu, "pageSize": 100]
        let endpoint = Endpoint<DistrictsResponse>(
            baseURL: .imdangAPI,
            path: "/districts/eup-myeon-dong",
            method: .get,
            headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: parameters
        )
        
        return networkManager.request(with: endpoint)
            .map { data in
                var result: [String: [String]] = [:]
                data.toAddresses().filter { $0.eupMyeonDong != "" || $0.eupMyeonDong != nil }.forEach {
                    result[$0.siGunGu, default: [String]()].append($0.eupMyeonDong!)
                }
                return result.mapValues { $0.sorted() }
            }
            .catch { error in
                print("Error: \(error.localizedDescription)")
                return Observable.just(nil)
            }
    }
}
