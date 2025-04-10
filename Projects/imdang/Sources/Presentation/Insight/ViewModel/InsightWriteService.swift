//
//  InsightWriteService.swift
//  SharedLibraries
//
//  Created by 임대진 on 1/17/25.
//

import UIKit
import NetworkKit
import RxSwift
import Alamofire

final class InsightWriteService {
    static let shared = InsightWriteService()
    
    private var disposeBag = DisposeBag()
    private let networkManager = NetworkManager()
    
    func createInsight(dto: InsightDTO, images: [UIImage]) -> Observable<Bool> {
        
        guard let jsonData = try? JSONEncoder().encode(dto) else {
            return Observable.just(false)
        }
        
        let endpoint = MultipartEndpoint<InsightIdResponse>(
            baseURL: .imdangAPI,
            path: dto.insightId == nil ? "/insights/create" : "/insights/update",
            method: .post,
            headers: [.authorization(bearerToken: UserdefaultKey.accessToken)],
            images: images,
            jsonData: jsonData,
            isCreate: dto.insightId == nil
        )
        
        return networkManager.upload(with: endpoint)
            .map { _ in
                return true
            }
            .catch { error in
                print("Error: \(error.localizedDescription)")
                return Observable.just(false)
            }
    }
    
    func getCoordinates(address: String, completion: @escaping (Double?, Double?) -> Void) {

        let url = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=\(address)"
        
        if let APIID = Bundle.main.object(forInfoDictionaryKey: "NAVER_APP_KEY_ID") as? String, let APIKEY = Bundle.main.object(forInfoDictionaryKey: "NAVER_APP_KEY") as? String {
            let headers: HTTPHeaders = [
                "X-NCP-APIGW-API-KEY-ID": APIID,
                "X-NCP-APIGW-API-KEY": APIKEY,
                "Accept": "application/json"
            ]

            AF.request(url, method: .get, headers: headers)
                .validate()
                .responseDecodable(of: NaverGeocodeResponse.self) { response in
                    switch response.result {
                    case .success(let result):
                        if let firstResult = result.addresses.first {
                            let latitude = Double(firstResult.y)
                            let longitude = Double(firstResult.x)
                            completion(latitude, longitude)
                        } else {
                            completion(nil, nil)
                        }
                    case .failure(let error):
                        print("네이버 Geocoding API 오류: \(error)")
                        completion(nil, nil)
                    }
                }
        }
    }
}

struct NaverGeocodeResponse: Codable {
    let status: String
    let meta: Meta
    let addresses: [Address]
    let errorMessage: String?
    
    struct Meta: Codable {
        let totalCount: Int
        let page: Int
        let count: Int
    }
    
    struct Address: Codable {
        let roadAddress: String
        let jibunAddress: String
        let englishAddress: String
        let addressElements: [AddressElement]
        let x: String  // 경도 (Longitude)
        let y: String  // 위도 (Latitude)
        let distance: Double
    }
    
    struct AddressElement: Codable {
        let types: [String]
        let longName: String
        let shortName: String
        let code: String
    }
}
