//
//  UserDefault.swift
//  Imdangg
//
//  Created by 임대진 on 11/3/24.
//

import Foundation

enum SignInType: String {
    case apple = "apple"
    case kakao = "kakao"
    case google = "google"
}

enum UserdefaultKey {
    // 저장: UserdefaultKey.test = "~~"
    // 읽기: let test = UserdefaultKey.test
    @UserDefault(key: "isJoined", defaultValue: false)
    static var isJoined: Bool {
        didSet {
            UserdefaultKey.isSiginedIn = UserdefaultKey.isJoined
        }
    }
    
    @UserDefault(key: "isSiginedIn", defaultValue: false)
    static var isSiginedIn: Bool
    
    @UserDefault(key: "memberId", defaultValue: "")
    static var memberId: String
    
    @UserDefault(key: "memberNickname", defaultValue: "")
    static var memberNickname: String
    
    @UserDefault(key: "deviceToken", defaultValue: "")
    static var deviceToken: String
    
    @UserDefault(key: "accessToken", defaultValue: "")
    static var accessToken: String
    
    @UserDefault(key: "refreshToken", defaultValue: "")
    static var refreshToken: String
    
    @UserDefault(key: "tokenTimeInterval", defaultValue: nil)
    static var tokenTimeInterval: Double?
    
    @UserDefault(key: "dontSeeToday", defaultValue: "")
    static var dontSeeToday: String
    
    @UserDefault(key: "couponReceived", defaultValue: false)
    static var couponReceived: Bool
    
    @UserDefault(key: "homeToolTip", defaultValue: false)
    static var homeToolTip: Bool
    
    @UserDefault(key: "wirteToolTip", defaultValue: false)
    static var wirteToolTip: Bool
    
    @UserDefault(key: "signInType", defaultValue: "")
    static var signInType: String
    
    //탈퇴시 적용
    static func resetUserDefaults() {
        UserdefaultKey.isJoined = false
        UserdefaultKey.isSiginedIn = false
        UserdefaultKey.memberId = ""
        UserdefaultKey.memberNickname = ""
        UserdefaultKey.accessToken = ""
        UserdefaultKey.refreshToken = ""
        UserdefaultKey.tokenTimeInterval = Date().timeIntervalSince1970
        UserdefaultKey.dontSeeToday = ""
        UserdefaultKey.couponReceived = false
        UserdefaultKey.homeToolTip = false
        UserdefaultKey.wirteToolTip = false
        UserdefaultKey.signInType = ""
        
        UserDefaults.standard.synchronize()
    }
}


@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
