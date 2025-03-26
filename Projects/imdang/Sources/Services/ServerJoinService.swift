//
//  ServerJoinService.swift
//  imdang
//
//  Created by 임대진 on 1/15/25.
//

import UIKit
import NetworkKit
import RxSwift
import Alamofire

enum companyType {
    case google, kakao
}

class ServerJoinService {
    static let shared = ServerJoinService()
    
    private var disposeBag = DisposeBag()
    private let networkManager = NetworkManager()
    
    func joinImdang(nickname: String, birthDate: String?, gender: Gender) -> Observable<Bool> {
        var parameters: [String: String] = [
            "nickname": nickname,
            "deviceToken": UserdefaultKey.deviceToken
        ]
        if let birthDate = birthDate {
            parameters["birthDate"] = birthDate
        }
        if gender != .none {
            parameters["gender"] = gender.rawValue
        }
        
        let endpoint = Endpoint<BasicResponse>(
            baseURL: .imdangAPI,
            path: "/auth/join",
            method: .put,
            headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: parameters
        )
        
        return networkManager.requestOptional(with: endpoint)
            .map { _ in
                UserdefaultKey.isSiginedIn = true
                return true
            }
            .catch { error in
                print("Error: \(error.localizedDescription)")
                return Observable.just(false)
            }
    }
    
    func termsAgree(agreeIndex: [Int]) -> Observable<Bool> {
        let parameters: [String: Any] = [
            "termsIds": agreeIndex.sorted(),
            "memberId": UserdefaultKey.memberId
        ]
        
        let endpoint = Endpoint<BasicResponse>(
            baseURL: .imdangAPI,
            path: "/terms/agree",
            method: .post,
            headers: [.contentType("application/json"), .authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: parameters
        )
        
        return networkManager.requestOptional(with: endpoint)
            .map { _ in
                return true
            }
            .catch { error in
                print("Error: \(error.localizedDescription)")
                return Observable.just(false)
            }
    }
    
    func checkTokenExpired(splash: Bool = false) {
        if splash && UserdefaultKey.isSiginedIn == true {
            tokenReissue()
                .subscribe { result in
                    print(result ? "토근 갱신 완료" : "토근 갱신 실패")
                    if result == false {
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(SigninViewController(), animated: true)
                    }
                }
                .disposed(by: disposeBag)
        } else {
            guard let savedTime = UserdefaultKey.tokenTimeInterval else { return }
            let expirationTime: TimeInterval = 18000
            let currentTime = Date().timeIntervalSince1970
            
            if (currentTime - savedTime) >= expirationTime {
                tokenReissue()
                    .subscribe { result in
                        print(result ? "토근 갱신 완료" : "토근 갱신 실패")
                        if result == false {
                            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(SigninViewController(), animated: true)
                        }
                    }
                    .disposed(by: disposeBag)
            } else {
                print("토큰 만료 \((savedTime + expirationTime) - currentTime)초전")
            }
        }
    }
    
    private func tokenReissue() -> Observable<Bool> {
        let parameters: [String: Any] = [
            "memberId": UserdefaultKey.memberId,
            "refreshToken": UserdefaultKey.refreshToken
        ]
        
        let endpoint = Endpoint<TokenResponse>(
            baseURL: .imdangAPI,
            path: "/auth/reissue",
            method: .post,
            headers: [.contentType("application/json")],
            parameters: parameters
        )
        
        return networkManager.requestOptional(with: endpoint)
            .map { result in
                if let result = result {
                    UserdefaultKey.accessToken = result.accessToken
                    UserdefaultKey.refreshToken = result.refreshToken
                    UserdefaultKey.tokenTimeInterval = Date().timeIntervalSince1970
                }
                return true
            }
            .catch { error in
                print("Error: \(error.localizedDescription)")
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(SigninViewController(), animated: true)
                return Observable.just(false)
            }
    }
}

