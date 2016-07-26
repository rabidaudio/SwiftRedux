//
//  BaseStore.swift
//  SwiftRedux
//
//  Created by Charles Julian Knight on 7/25/16.
//  Copyright © 2016 Charles Julian Knight. All rights reserved.
//

import Foundation

// Basic Store with no ability for observation of state changes
public class BaseStore<State,Action> {
    public typealias Reducer = (prevState: State, action: Action) -> State
    public typealias Dispatcher = Action -> Void
    public typealias DispatchCreator = Dispatcher -> Dispatcher
    public typealias Middleware = BaseStore -> DispatchCreator
    
    private let reducer: Reducer
    
    public var state: State
    
    public var middleware: [Middleware] = [] {
        didSet {
            setupBaseDispatcher()
        }
    }
    
    private var baseDispatcher: Dispatcher!
    
    public init(withState initialState: State, middleware: [Middleware], reducer: Reducer){
        self.state = initialState
        self.reducer = reducer
        self.middleware = middleware
        setupBaseDispatcher()
    }
    
    private func setupBaseDispatcher(){
        let rootDispatcher = self.baseDispatch
        var nextDispatcher = rootDispatcher
        for m in middleware {
            nextDispatcher = m(self)(nextDispatcher)
        }
        baseDispatcher = nextDispatcher
    }
    
    private func baseDispatch(action: Action) {
        state = self.reducer(prevState: state, action: action)
    }
    
    // build up middleware and call
    public func dispatch(action: Action) {
        baseDispatcher(action)
    }
}