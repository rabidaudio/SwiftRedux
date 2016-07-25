//
//  CombinedReducer.swift
//  SwiftRedux
//
//  Created by Charles Julian Knight on 7/25/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

// Compose a group of Reducers down to a single Reducer.
// Example:
//   CombinedReducer(TODOReducer(), VisibilityFilterReducer()).create()
class CombinedReducer<State,Action> {
    typealias Reducer = ((prevState: State, action: Action) -> State)
    
    private let reducers: [Reducer]
    
    init(_ reducers: [Reducer]){
        self.reducers = reducers
    }
    
    convenience init(_ reducers: Reducer...){
        self.init(reducers)
    }
    
    private func reduce(oldState: State, action: Action) -> State {
        var newState = oldState
        for reducer in reducers {
            newState = reducer(prevState: newState, action: action)
        }
        return newState
    }
    
    func combine() -> Reducer {
        return self.reduce
    }
}