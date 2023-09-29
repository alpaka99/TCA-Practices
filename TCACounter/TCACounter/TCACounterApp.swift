//
//  TCACounterApp.swift
//  TCACounter
//
//  Created by user on 2023/09/29.
//

import ComposableArchitecture
import SwiftUI

@main
struct TCACounterApp: App {
    var body: some Scene {
        WindowGroup {
//            ContentView()
            CounterView(store: Store(initialState: CounterFeature.State()) {
                CounterFeature()
                    ._printChanges()
            })
        }
    }
}
