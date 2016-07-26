//
//  TestHelpers.swift
//  SwiftRedux
//
//  Created by Charles Julian Knight on 7/25/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import SwiftRedux

class CallCounterReducer<S,A> {
    
    private(set) var callCount = 0
    
    func reduce(state: S, action: A) -> S {
        callCount += 1
        return state
    }    
}

struct ExampleState {
    var x: Int
    var y: Bool
    var errorMessage: String?
}

enum MyErrorType: ErrorType {
    case ExampleError(message: String)
}

enum ExampleAction {
    case NoOp
    case ToggleY
    case SetX(newX: Int)
    
    case ErrorAction(error: ErrorType)
}

func ==(lhs: ExampleAction, rhs: ExampleAction) -> Bool {
    switch lhs {
    case .NoOp:
        return rhs == .NoOp
    case .ToggleY:
        return rhs == .ToggleY
    case .SetX(let newX):
        return rhs == .SetX(newX: newX)
    case .ErrorAction(let error):
        return rhs == .ErrorAction(error: error)
    }
}

let ExampleReducer: (prevState: ExampleState, action: ExampleAction) -> ExampleState = { prevSate, action -> ExampleState in
    var newState = prevSate
    switch action {
    case .ToggleY:
        newState.y = !newState.y
    case .SetX(let newX):
        newState.x = newX
    case .ErrorAction(let error):
        switch error {
        case MyErrorType.ExampleError(let message):
            newState.errorMessage = message
        default:
            break
        }
    default:
        break
    }
    return newState
}

class GenericMiddleware<S,A> {
    typealias T = BaseStore<S,A>
    
    private(set) var lastStore: T?
    private(set) var createCallCount = 0
    private(set) var dispatchCreatorCallCount = 0
    
    func create(store: T) -> T.DispatchCreator {
        self.lastStore = store
        createCallCount += 1
        return { next in
            self.dispatchCreatorCallCount += 1
            return { a in
                next(a)
            }
        }
    }
}

class NoOpMiddleware<S,A> {
    typealias T = BaseStore<S,A>
    
    func create(store: T) -> T.DispatchCreator {
        return { next -> T.Dispatcher in { next($0) } }
    }
}

class RxStoreWithErrorHandler: RXStore<ExampleState,ExampleAction> {
    
    init(withState initialState: ExampleState, reducer: (prevState: ExampleState, action: ExampleAction) -> ExampleState) {
        super.init(withState: initialState, middleware: [], reducer: reducer)
    }
    
    override func errorAction(error: ErrorType) -> ExampleAction? {
        return ExampleAction.ErrorAction(error: error)
    }
}

class PKStoreWithErrorHandler: PKStore<ExampleState,ExampleAction> {
    
    init(withState initialState: ExampleState, reducer: (prevState: ExampleState, action: ExampleAction) -> ExampleState) {
        super.init(withState: initialState, middleware: [], reducer: reducer)
    }
    
    override func errorAction(error: ErrorType) -> ExampleAction? {
        return ExampleAction.ErrorAction(error: error)
    }
}