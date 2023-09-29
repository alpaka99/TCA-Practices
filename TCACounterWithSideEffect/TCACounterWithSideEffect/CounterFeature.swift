//
//  CounterFeature.swift
//  TCACounterWithSideEffect
//
//  Created by user on 2023/09/29.
//

import ComposableArchitecture
import SwiftUI


struct CounterFeature: Reducer {
    struct State {
        var count: Int = 0
        var fact: String?
        var isLoading = false
        var isTimmerRunning = false
    }
    
    enum Action {
        case incrementButtonTapped
        case decrementButtonTapped
        case factButtonTapped
        case factResponse(String)
        case toggleTimerButtonTapped
        case timerTick
    }
    
    enum CancelID {
        case timer
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .incrementButtonTapped:
            state.count += 1
            state.fact = nil
            return .none
            
        case .decrementButtonTapped:
            state.count -= 1
            state.fact = nil
            return .none
            
            
        case .factButtonTapped:
            state.fact = nil
            state.isLoading = true
            
//            let (data, _) = try await URLSession.shared.data(from: URL(string: "https://numbersapi.com/\(state.count)")!)


//            state.fact = String(decoding: data, as: UTF8.self)
//            state.isLoading = false
            // 이렇게 직접 주입하는건 2가지 에러가 발생함
            // 1. 'async' call in a function that does not support concurrency
            // 2. Errors thrown from here are not handeld
            
            // 따라서 return 하는 Effect에서 처리를 해준다.
            return .run { [count = state.count] send in
                // Do asynchoronaus work here, and send action back into the system
                // 즉, 여기서 비동기 작업을 진행하고, reducer로 다시 action을 넣어준다.
                let (data, _) = try await URLSession.shared
                          .data(from: URL(string: "http://numbersapi.com/\(count)")!)
                let fact = String(decoding: data, as: UTF8.self)
                // 여기서 직접 fact 라는 state를 변경하는건 compiler가 막음
                // 왜냐하면 sendable closure는 inout state를 capture할 수 없기 때문이다.
                // 이래서 composable architecture library가 reducer가 실행하는 간단하고 순수한 state 변형과 지저분하고 복잡한 effect를 나누는것이다.
                
                
                // 그러면 어떻게 Effect에서 받아온 이 정보를 다시 Reducer 안으로 넣어줄 수 있을까??
                
                await send(.factResponse(fact))
            }
            
        case let .factResponse(fact):
            state.fact = fact
            state.isLoading = false
            print(fact)
            return .none
            
        case .toggleTimerButtonTapped:
            state.isTimmerRunning.toggle()
            if state.isTimmerRunning {
                return .run { send in
                    while true {
                        try await Task.sleep(for: .seconds(1))
                        await send(.timerTick)
                    }
                }
                .cancellable(id: CancelID.timer)
            } else {
                return .cancel(id: CancelID.timer)
            }
            
        
        case .timerTick:
            state.count += 1
            state.fact = nil
            return .none
        }
    }
}

extension CounterFeature.State: Equatable {}


struct CounterView: View {
    let store: StoreOf<CounterFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Text("\(viewStore.state.count)")
                    .font(.largeTitle)
                     .padding()
                     .background(Color.black.opacity(0.1))
                     .cornerRadius(10)
                
                HStack {
                    Button("-") {
                        viewStore.send(.decrementButtonTapped)
                    }
                    .font(.largeTitle)
                     .padding()
                     .background(Color.black.opacity(0.1))
                     .cornerRadius(10)
                    
                    Button("+") {
                        viewStore.send(.incrementButtonTapped)
                    }
                    .font(.largeTitle)
                     .padding()
                     .background(Color.black.opacity(0.1))
                     .cornerRadius(10)
                }
                
                Button(viewStore.isTimmerRunning ? "Stop Timer":"Start Timer") {
                    viewStore.send(.toggleTimerButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)

                
                Button("Fact") {
                    viewStore.send(.factButtonTapped)
                }
                .font(.largeTitle)
                 .padding()
                 .background(Color.black.opacity(0.1))
                 .cornerRadius(10)
                
                if viewStore.isLoading {
                    ProgressView()
                } else if let fact = viewStore.fact {
                    Text(fact)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
        }
    }
}


//struct CounterViewPreview: PreviewProvider {
//    static var previews: some View {
//        CounterView(store: Store(initialState: CounterFeature.State()) {
//            CounterFeature()
//        })
//    }
//}
