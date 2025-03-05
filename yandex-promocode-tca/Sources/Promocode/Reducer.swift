//
//  Reducer.swift
//  yandex-promocode-tca
//
//  Created by Артём Зайцев on 05.03.2025.
//

import ComposableArchitecture

struct PromocodeReducer: Reducer {
    typealias State = PromocodeState
    typealias Action = PromocodeAction
    let env: Environment
    
    init(env: Environment) {
        self.env = env
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .internalAction(action):
            return internalReduce(into: &state, action: action)
        case let .viewAction(action):
            return viewReduce(into: &state, action: action)
        }
    }
    
    private func internalReduce(into state: inout State, action: Action.InternalAction) -> Effect<Action> {
        switch action {
        case .getPromocodes:
            return .run { send in
                let promocodes = try await env.getPromocodes()
                await send(.internalAction(.promocodesChanged(promocodes)))
                if let first = promocodes.first {
                    await send(.internalAction(.selectPromocode(first)))
                }
            }
        case let .promocodesChanged(promocodes):
            state.promocodes = promocodes
            return .none
        case let .selectPromocode(promocode):
            state.selectedPromocode = promocode
            return .none
        }
    }
    
    private func viewReduce(into state: inout State, action: Action.ViewAction) -> Effect<Action> {
        switch action {
        case let .sharePromocode(promocode):
            // Send event to firebase etc.
            return .none
            
        case let .changePromocode(direction):
            guard state.promocodes.count > 0,
                  let selectedPromocode = state.selectedPromocode,
                  let currentIndex = state.promocodes.firstIndex(of: selectedPromocode) else { return .none }
            
            switch direction {
            case .right:
                if state.promocodes.count - 1 == currentIndex {
                    guard let promocode = state.promocodes.first else { return .none }
                    return .send(.internalAction(.selectPromocode(promocode)))
                } else {
                    let promocode = state.promocodes[currentIndex + 1]
                    return .send(.internalAction(.selectPromocode(promocode)))
                }
            case .left:
                if currentIndex == 0 {
                    guard let promocode = state.promocodes.last else { return .none }
                    return .send(.internalAction(.selectPromocode(promocode)))
                } else {
                    let promocode = state.promocodes[currentIndex - 1]
                    return .send(.internalAction(.selectPromocode(promocode)))
                }
            }
        }
    }
}
