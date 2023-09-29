//
//  TCACounterWithSideEffectApp.swift
//  TCACounterWithSideEffect
//
//  Created by user on 2023/09/29.
//

import ComposableArchitecture
import SwiftUI

@main
struct TCACounterWithSideEffectApp: App {
    static let store = Store(initialState: CounterFeature.State()) {
        CounterFeature()
    }
    
    var body: some Scene {
        WindowGroup {
//            ContentView()
            CounterView(store: TCACounterWithSideEffectApp.store)
        }
    }
}
