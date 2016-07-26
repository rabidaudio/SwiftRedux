//
//  Store+PromiseKit.swift
//  SwiftRedux
//
//  Created by Charles Julian Knight on 7/25/16.
//  Copyright © 2016 Charles Julian Knight. All rights reserved.
//

#if REDUX_INCLUDE_PROMISEKIT

import Foundation
import PromiseKit

class Store<State,Action>: BaseStore<State,Action> {
    
    private var subscribers: [(Promise<State>, (State->Void),(ErrorType->Void))] = []
    
    private let lock = NSLock()
    
    override var state: State {
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
    
#endif