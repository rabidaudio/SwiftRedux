//
//  Store+PromiseKit.swift
//  SwiftRedux
//
//  Created by Charles Julian Knight on 7/25/16.
//  Copyright © 2016 Charles Julian Knight. All rights reserved.
//

import Foundation
import PromiseKit

public class PKStore<State,Action>: BaseStore<State,Action> {
    
    private var subscribers: [(Promise<State>, (State->Void),(ErrorType->Void))] = []
    
    private let lock = NSLock()
    
    public override init(withState initialState: State, middleware: [Middleware], reducer: Reducer) {
        super.init(withState: initialState, middleware: middleware, reducer: reducer)
    }
    
    override public var state: State {
        didSet {
            lock.lock()
            while !subscribers.isEmpty {
                if let (_, f, _) = subscribers.popLast() {
                    f(state)
                }
            }
            lock.unlock()
        }
    }
    
    public func dispatchAsync(promise: Promise<Action>) {
        promise.then { action in
            self.dispatch(action)
            }.error { error in
                if let action = self.errorAction(error) {
                    self.dispatch(action)
                }else{
                    print("warning: action promise errored but was not handled: \(error)")
                }
        }
    }
    
    public func errorAction(error: ErrorType) -> Action? {
        return nil
    }
    
    public func promiseNextChange() -> Promise<State> {
        lock.lock()
        let pp = Promise<State>.pendingPromise()
        subscribers.append(pp)
        lock.unlock()
        return pp.promise
    }
}