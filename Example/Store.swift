//
//  Store.swift
//  SwiftRedux
//
//  Created by Charles Julian Knight on 7/25/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

public class Store<State,Action> {
    typealias Reducer = ((prevState: State, action: Action) -> State)
    typealias Dispatcher = (Action -> Void)
    typealias DispatchCreator = (Dispatcher -> Dispatcher)
    typealias Middleware = (Store<State,Action> -> DispatchCreator)
    
    private let reducer: Reducer
    var middleware: [Middleware] = [] {
        didSet {
            buildBaseDispatcher()
        }
    }
    
    private var baseDispatcher: Dispatcher!
    
    private(set) var state: State
    
    init(withState initialState: State, middleware: [Middleware], reducer: Reducer){
        self.state = initialState
        self.reducer = reducer
        self.middleware = middleware
        buildBaseDispatcher()
    }
    
    private func buildBaseDispatcher(){
        let rootDispatcher = self.baseDispatch
        var nextDispatcher = rootDispatcher
        for m in middleware {
            nextDispatcher = m(self)(nextDispatcher)
        }
        baseDispatcher = nextDispatcher
    }
    
    private func baseDispatch(action: Action) {
        self.state = self.reducer(prevState: self.state, action: action)
    }
    
    func dispatch(action: Action) {
        baseDispatch(action)
    }
}