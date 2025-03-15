//
//  ExchangeViewReactor.swift
//  imdang
//
//  Created by daye on 12/5/24.
//

import Foundation
import ReactorKit

final class ExchangeReactor: Reactor {
    var currentSegmentState: ExchangeRequestState = .receive
    private var disposeBag = DisposeBag()
    
    struct State {
        var insights: [Insight]?
        var selectedExchangeState: ExchangeState
        var selectedRequestState: ExchangeRequestState
    }
    
    enum Action {
        case tapExchangeStateButton(ExchangeState)
        case selectedRequestSegmentControl(ExchangeRequestState)
        case loadInsights
    }
    
    enum Mutation {
        case changeSelectedExchangeState(ExchangeState)
        case changeSelectedRequestState(ExchangeRequestState)
        case setInsights([Insight]?)
    }
    
    var initialState: State
    let exChangeViewModel = ExchangeViewModel()
    
    init() {
        self.initialState = State(selectedExchangeState: .waiting, selectedRequestState: .request)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadInsights:
            let selectedRequestState = currentState.selectedRequestState
            let selectedExchangeState = currentState.selectedExchangeState
            currentSegmentState = currentState.selectedRequestState
            
            switch selectedRequestState {
            case .request:
                switch selectedExchangeState {
                case .waiting:
                    return exChangeViewModel.loadRequestedByMe(state: .pending)
                        .map { Mutation.setInsights($0) }
                case .done:
                    return exChangeViewModel.loadRequestedByMe(state: .accepted)
                        .map { Mutation.setInsights($0) }
                case .reject:
                    return exChangeViewModel.loadRequestedByMe(state: .rejected)
                        .map { Mutation.setInsights($0) }
                }
            case .receive:
                switch selectedExchangeState {
                case .waiting:
                    return exChangeViewModel.loadRequestedByOthers(state: .pending)
                        .map { Mutation.setInsights($0) }
                case .done:
                    return exChangeViewModel.loadRequestedByOthers(state: .accepted)
                        .map { Mutation.setInsights($0) }
                case .reject:
                    return exChangeViewModel.loadRequestedByOthers(state: .rejected)
                        .map { Mutation.setInsights($0) }
                }
            }
            case .tapExchangeStateButton(let exchangeState):
                return Observable.concat([
                    Observable.just(Mutation.changeSelectedExchangeState(exchangeState)),
                    Observable.just(Action.loadInsights).flatMap { action in
                        return self.mutate(action: action)
                    }
                ])
            
            case .selectedRequestSegmentControl(let requestState):
                return Observable.concat([
                    Observable.just(Mutation.changeSelectedRequestState(requestState)),
                    Observable.just(Action.loadInsights).flatMap { action in
                        return self.mutate(action: action)
                    }
                ])
            }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case .changeSelectedExchangeState(let exchangeState):
            state.selectedExchangeState = exchangeState
        case .changeSelectedRequestState(let requestState):
            state.selectedRequestState = requestState
        case let .setInsights(insights):
            state.insights = insights
        }
        return state
    }
}
