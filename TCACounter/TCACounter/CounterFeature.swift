//
//  CounterFeature.swift
//  TCACounter
//
//  Created by user on 2023/09/29.
//

import ComposableArchitecture
import SwiftUI

struct CounterFeature: Reducer {
    struct State {
        var count = 0
    }
    
    enum Action {// action은 유저가 UI에 하는 행동을 따서 이름짓기
        case decrementButtonTapped
        case incrementButtonTapped
    }
    
    func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        switch action {
        case .decrementButtonTapped:
            state.count -= 1
            return .none
            
        case .incrementButtonTapped:
            state.count += 1
            return .none
        }
    }
}

extension CounterFeature.State: Equatable {}


struct CounterView: View {
    let store: StoreOf<CounterFeature>
    var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            VStack {
                Text("\(viewStore.count)")
                    .font(.largeTitle)
                    .padding()
                    .background(.black.opacity(0.1))
                    .cornerRadius(10)
                
                HStack {
                    Button("-") {
                        viewStore.send(.decrementButtonTapped)
                    }
                    .font(.largeTitle)
                    .padding()
                    .background(.black.opacity(0.1))
                    .cornerRadius(10)
                    
                    Button("+") {
                        viewStore.send(.incrementButtonTapped)
                    }
                    .font(.largeTitle)
                    .padding()
                    .background(.black.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
    }
}


struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(
            store: Store(initialState: CounterFeature.State()) {
                CounterFeature()
            }
        )
    }
}
