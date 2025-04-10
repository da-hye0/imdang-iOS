//
//  InsightViewReactor.swift
//  imdang
//
//  Created by daye on 12/31/24.
//

import RxSwift
import RxRelay
import ReactorKit
import UIKit

class InsightReactor: Reactor {
    let disposeBag = DisposeBag()
    let insightService = InsightWriteService()
    
    var detail = InsightDetail.emptyInsight
    var mainImage: UIImage?
    var updateInsightId: String?
    var scoreRecord = [Int]()
    
    struct State {
        var isChangeScore = 0
        var isShowingCameraSheet: Bool = false
        var isUploadSuccess: Bool = false
        var setCurrentCategory: Int = 0
        // infoBaseView
        var selectedItems: [[String]] = Array(repeating: [], count: 8)
        var checkSectionState: [TextFieldState] = Array(repeating: .normal, count: 8)
    }
    
    enum Action {
        case tapCameraSheet(Bool)
        case tapBackButton
        case tapBaseInfoConfirm(InsightDetail, UIImage?)
        case tapInfraInfoConfirm(Infrastructure)
        case tapEnvironmentInfoConfirm(Environment)
        case tapFacilityInfoConfirm(Facility)
        case tapFavorableNewsInfoConfirm(FavorableNews)
        //        case selectItems(IndexPath, [String])
        case updateSectionState(Int, TextFieldState)
    }
    
    enum Mutation {
        case showingCameraSheet(Bool)
        case updateBaseInfo(InsightDetail, UIImage?)
        case updateInfra(Infrastructure)
        case updateEnvironment(Environment)
        case updateFacility(Facility)
        case setUploadSuccess(Bool)
        case backSubview
        //        case updateSelectedItems(IndexPath, [String])
        
        case updateSectionNewState(Int, TextFieldState)
    }
    
    let initialState = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapCameraSheet(let isShowingSheet):
            return Observable.just(.showingCameraSheet(isShowingSheet))
            //        case .selectItems(let indexPath, let selectedArray):
            //            return Observable.just(.updateSelectedItems(indexPath, selectedArray))
            //        }
        case .tapBaseInfoConfirm(let info, let image):
            
            return Observable.just(.updateBaseInfo(info, image))
        case .tapInfraInfoConfirm(let info):
            
            return Observable.just(.updateInfra(info))
        case .tapEnvironmentInfoConfirm(let info):
            
            return Observable.just(.updateEnvironment(info))
        case .tapFacilityInfoConfirm(let info):
            
            return Observable.just(.updateFacility(info))
        case .tapFavorableNewsInfoConfirm(let info):
            detail.favorableNews = info
            addScore(haveText: detail.favorableNews.text != "")
            
            if let image = mainImage {
                var data = detail.toDTO()
                data.insightId = updateInsightId
                return insightService.createInsight(dto: data, images: [image])
                    .map { success in
                        print("Upload success state updated: \(success)")
                        self.detail.memberNickname = UserdefaultKey.memberNickname
                        return Mutation.setUploadSuccess(success)
                    }
                    .catch { error in
                        print("Error: \(error)")
                        return Observable.just(Mutation.setUploadSuccess(false))
                    }
            } else {
                print("mainImage not found")
                return Observable.just(Mutation.setUploadSuccess(false))
            }
            
        case .tapBackButton:
            return Observable.just(.backSubview)
            
        case .updateSectionState(let section, let newStateValue):
            return Observable.just(.updateSectionNewState(section, newStateValue))
        }
     
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
            
        case .showingCameraSheet(let isShowingSheet):
            newState.isShowingCameraSheet = isShowingSheet
            //        case .updateSelectedItems(let indexPath, let selectedArray):
            ////            newState.selectedItems[indexPath] = selectedArray
            //        }
            
        case .updateBaseInfo(let info, let image):
            detail = info
            mainImage = image
            addScore(haveText: true)
            
            newState.isChangeScore = detail.score
            newState.setCurrentCategory = 1
            
        case .updateInfra(let info):
            detail.infra = info
            addScore(haveText: detail.infra.text != "")
            
            newState.isChangeScore = detail.score
            newState.setCurrentCategory = 2
            
        case .updateEnvironment(let info):
            detail.complexEnvironment = info
            addScore(haveText: detail.complexEnvironment.text != "")
            
            newState.isChangeScore = detail.score
            newState.setCurrentCategory = 3
            
        case .updateFacility(let info):
            detail.complexFacility = info
            addScore(haveText: detail.complexFacility.text != "")
            
            newState.isChangeScore = detail.score
            newState.setCurrentCategory = 4
            
        case .setUploadSuccess(let success):
            newState.isUploadSuccess = success
            
        case .backSubview:
            removeScore()
            
            newState.isChangeScore = detail.score
            newState.setCurrentCategory -= 1
            
        case .updateSectionNewState(let section, let newStateValue):
            newState.checkSectionState[section] = newStateValue
        }
        
        return newState
    }
    
    private func addScore(haveText: Bool) {
        if haveText {
            scoreRecord.append(20)
        } else {
            scoreRecord.append(10)
        }
        detail.score += scoreRecord.last ?? 0
    }
    
    private func removeScore() {
        detail.score -= scoreRecord.popLast() ?? 0
    }
}
