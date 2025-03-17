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

    func createInsight(dto: InsightDTO, image: UIImage) -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            guard let value = Bundle.main.object(forInfoDictionaryKey: "IMDANG_DEV_API") as? String, let baseUrl = value.removingPercentEncoding else {
                observer.onNext(false)
                observer.onCompleted()
                return Disposables.create()
            }
            
            let url = dto.insightId == nil ? baseUrl+"/insights/create" : baseUrl+"/insights/update"
            
            guard let jsonData = try? JSONEncoder().encode(dto) else {
                return Disposables.create()
            }
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(UserdefaultKey.accessToken)"
            ]
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(jsonData, withName: dto.insightId == nil ? "createInsightCommand" : "updateInsightCommand", mimeType: "application/json")
                
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    multipartFormData.append(imageData, withName: "mainImage", fileName: "image.jpeg", mimeType: "image/jpeg")
                }
                
            }, to: url, method: .post, headers: headers)
            .validate()
            .response { response in
                if (200..<300).contains(response.response?.statusCode ?? 0) {
                    
                    if let data = response.data, !data.isEmpty {
                        print("""
                        📲 NETWORK Response LOG
                        📲 StatusCode: \(response.response?.statusCode ?? 0)
                        📲 Data: \(response.data?.toPrettyPrintedString ?? "")
                        """)
                        observer.onNext(true)
                        observer.onCompleted()
                    } else {
                        observer.onNext(false)
                        observer.onCompleted()
                    }
                } else {
                    if let errorData = response.data {
                        do {
                            let decodedError = try JSONDecoder().decode(BasicResponse.self, from: errorData)
                            print("❌ 에러 메세지: \(decodedError.message)")
                            print("❌ 에러 코드: \(response.response?.statusCode ?? -1)")
                        } catch {
                            observer.onError(error)
                        }
                    } else {
                        observer.onError(NSError(domain: "Network Error", code: response.response?.statusCode ?? -1, userInfo: nil))
                    }
                }
            }
            return Disposables.create()
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
