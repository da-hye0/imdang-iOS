//
//  AnalyticsService.swift
//  imdang
//
//  Created by 임대진 on 2/15/25.
//

import Foundation
import FirebaseAnalytics

enum AnalyticsEventScreen: String {
    case splash = "스플래쉬"
    case signIn = "로그인"
    case onBoarding = "온보딩"
    case userInfoInput = "기본정보입력"
    case isJoined = "가입완료"
    case homeSearch = "홈_탐색"
    case homeExchange = "홈_교환소"
    case myVisitInsights = "내가 다녀온 단지의 다른 인사이트"
    case todayNewInsights = "오늘 새롭게 올라온 인사이트"
    case searchToDistrictDetail = "지역으로 찾기_상세"
    case StorageBox = "보관함"
    case listOfInsightsByDistrict = "지역별 인사이트 목록"
    case insightWriting = "인사이트 작성"
    case basicInfoSummary = "기본정보 요약"
    case infraSummary = "인프라 총평"
    case environmentSummary = "단지 환경 총평"
    case FacilitySummary = "단지 시설 총평"
    case FavoriteNewsSummary = "호재 총평"
    case insightDetail = "인사이트 상세"
    case mypage = "마이페이지"
    case serviceTerms = "서비스 이용 약관"
    case serviceIntroduction = "서비스 소개"
    case withdrawal = "계정 탈퇴"
    case searchingWithMap = "지도로 탐색"
    case findWithMap = "지도로 찾기"
    case notification = "알림"
}

final class AnalyticsService {
    static let shared = AnalyticsService()
    
    func screenEvent(ScreenName: AnalyticsEventScreen) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [ AnalyticsParameterScreenName: ScreenName.rawValue ])
    }
    
    // MARK: - 홈 탐색
    
    /// 홈_탐색
    func homeSearch() {
        let event = "홈_탐색"
        let parameters = [
            "category": "홈_탐색"
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 인사이트 탐색
    func insightSearch() {
        let event = "인사이트 탐색"
        let parameters = [
            "category": "홈_탐색",
            "action": "지역별 인사이트 탐색_click"
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 지도 (탐색)
    func searchMapButtonClick() {
        let event = "지도(탐색)"
        let parameters = [
            "category": "홈_탐색",
            "action": "홈_지도_click"
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 탐색 마이페이지
    func searchMypageButtonClick() {
        let event = "마이페이지"
        let parameters = [
            "category": "홈_탐색",
            "action": "탐색_마이페이지_click"
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 탐색 알림
    func searchNotiButtonClick() {
        let event = "알림"
        let parameters = [
            "category": "홈_탐색",
            "action": "탐색_알림_click"
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 메인배너
    func bannerClick() {
        let event = "메인배너"
        let parameters = [
            "category": "홈_탐색",
            "action": "메인배너_click"
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 내가 작성한 단지 인사이트 (단지명)
    func insightComplexClick(aptName: String) {
        let event = "내가 작성한 단지 인사이트(단지명)"
        let parameters = [
            "category": "홈_탐색",
            "action": "내가 작성_단지_click",
            "label": aptName
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 내가 작성한 단지 인사이트 (인사이트)
    func insightClick(insightName: String) {
        let event = "내가 작성한 단지 인사이트(인사이트)"
        let parameters = [
            "category": "홈_탐색",
            "action": "내가 작성_인사이트_click",
            "label": insightName
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 내가 작성한 단지 인사이트 (전체보기)
    func insightFullClick() {
        let event = "내가 작성한 단지 인사이트(전체보기)"
        let parameters = [
            "category": "홈_탐색",
            "action": "내가 작성_전체보기_click"
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 오늘 새롭게 올라온 인사이트 (인사이트)
    func todayNewInsightClick(insightName: String) {
        let event = "오늘 새롭게 올라온 인사이트(인사이트)"
        let parameters = [
            "category": "홈_탐색",
            "action": "신규_인사이트_click",
            "label": insightName
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 오늘 새롭게 올라온 인사이트 (전체보기)
    func todayNewInsightFullClick() {
        let event = "오늘 새롭게 올라온 인사이트(전체보기)"
        let parameters = [
            "category": "홈_탐색",
            "action": "신규_전체보기_click"
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 추천수 Top10 인사이트(인사이트)
    func topTenInsightClick(insightName: String) {
        let event = "추천수 Top10 인사이트(인사이트)"
        let parameters = [
            "category": "홈_탐색",
            "action": "추천_인사이트_click",
            "label": insightName
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 추천수 Top10 인사이트(스와이프)
    func topTenInsightSwipe() {
        let event = "추천수 Top10 인사이트(스와이프)"
        let parameters = [
            "category": "홈_탐색",
            "action": "추천_인사이트_swipe"
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// GNB_bottom_home
    func fromSearchTabbarClick(label: String) {
        let event = "GNB_bottom_home"
        let parameters = [
            "category": "홈_탐색",
            "action": "GNB_bottom_click",
            "label": label
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    // MARK: - 홈 교환소
    
    /// 홈_교환소
    func homeExchange() {
        let event = "홈_교환소"
        let parameters = [
            "category": "홈_교환소"
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 내가 요청한 내역 (교환상태)
    func sendRequestStateClick(state: String) {
        let event = "내가 요청한 내역(교환상태)"
        let parameters = [
            "category": " 홈_교환소",
            "action": "요청한내역_상태_click",
            "label": state
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 내가 요청한 내역 (인사이트)
    func sendRequestInsightClick(insightName: String) {
        let event = "내가 요청한 내역(인사이트)"
        let parameters = [
            "category": " 홈_교환소",
            "action": "요청한내역_인사이트_click",
            "label": insightName
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 요청 받은 내역(교환상태)
    func receivedRequestStateClick(state: String) {
        let event = "요청 받은 내역(교환상태)"
        let parameters = [
            "category": " 홈_교환소",
            "action": "요청받은내역_상태_click",
            "label": state
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 요청 받은 내역(인사이트)
    func receivedRequestInsightClick(insightName: String) {
        let event = "요청 받은 내역(인사이트)"
        let parameters = [
            "category": " 홈_교환소",
            "action": "요청받은내역_인사이트_click",
            "label": insightName
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 교환소 마이페이지
    func exchangeMypageButtonClick() {
        let event = "마이페이지"
        let parameters = [
            "category": " 홈_교환소",
            "action": "교환소_마이페이지_click"
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 교환소 알림
    func exchangeNotiButtonClick() {
        let event = "알림"
        let parameters = [
            "category": " 홈_교환소",
            "action": "교환소_알림_click"
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// GNB_bottom_home
    func fromExchangeTabbarClick(label: String) {
        let event = "GNB_bottom_home"
        let parameters = [
            "category": "홈_교환소",
            "action": "GNB_bottom_click",
            "label": label
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    // MARK: - 보관함
    
    /// 보관 단지 및 인사이트 수
    func storageBoxFullClick() {
        let event = "보관 단지 및 인사이트 수"
        let parameters = [
            "category": "보관함",
            "action": "지역_전체보기_click"
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 보관 단지 및 인사이트 수 (지역)
    func storageBoxSwipe() {
        let event = "보관 단지 및 인사이트 수(지역)"
        let parameters = [
            "category": "보관함",
            "action": "지역_swipe"
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 지도 (보관)
    func storageBoxMapButtonClick() {
        let event = "지도(보관)"
        let parameters = [
            "category": "보관함",
            "action": "보관함_지도_click"
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 인사이트 보관 리스트(단지)
    func storagefilterClick(aptName: String) {
        let event = "인사이트 보관 리스트(단지)"
        let parameters = [
            "category": "보관함",
            "action": "보관함_단지_click",
            "label": aptName
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 인사이트 보관 리스트(필터) off→on으로 변환될 때만 수집
    func storageMyFilterOn() {
        let event = "인사이트 보관 리스트(필터)"
        let parameters = [
            "category": "보관함",
            "action": "필터_click"
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 인사이트 보관 리스트(인사이트)
    func storageInsightClick(insightName: String) {
        let event = "인사이트 보관 리스트(인사이트)"
        let parameters = [
            "category": "보관함",
            "action": "보관함_인사이트_click",
            "label": insightName
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// GNB_bottom_home
    func fromStorageTabbarClick(label: String) {
        let event = "GNB_bottom_home"
        let parameters = [
            "category": "보관함",
            "action": "GNB_bottom_click",
            "label": label
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    // MARK: - 인사이트 작성
    
    /// 인사이트 작성완료
    func insightWrite() {
        let event = "인사이트 작성완료"
        let parameters = [
            "category": "인사이트_작성_상세",
            "action": "작성완료_click"
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    // MARK: - 인사이트 상세
    
    /// 인사이트 교환
    func insightExchangeState(state: String) {
        let event = "인사이트 교환"
        let parameters = [
            "category": "인사이트_작성_상세",
            "action": "인사이트상세_상태_click",
            "label": state
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    /// 인사이트 상세 추천
    func insightLike(isOn: Bool) {
        let event = "인사이트 상세 추천"
        let parameters = [
            "category": "인사이트_상세",
            "action": "인사이트상세_추천_click",
            "label": isOn ? "추천 on" : "추천 off"
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
    
    // MARK: - 알림
    
    /// 알림
    func notiCategoryClick(label: String) {
        let event = "알림"
        let parameters = [
            "category": "알림",
            "action": "알림_카테고리_click",
            "label": label
        ]
        
//        print(parameters)
        Analytics.logEvent(event, parameters: parameters)
    }
}
