//
//  Store+Rx.swift
//  SwiftRedux
//
//  Created by Charles Julian Knight on 7/25/16.
//  Copyright © 2016 Charles Julian Knight. All rights reserved.
//

#if REDUX_INCLUDE_RX

import Foundation
import RxSwift

// Store which observes actions and whose state is observable
public class Store<State,Action>: Store<State,Action>, ObservableType {
    typealias E = State
    
    private let _state: Variable<State>
    
    lazy private(set) var rx_dispatcher: AnyObserver<Action> = {
        return AnyObserver { event in
            switch event {
            case .Next(let action):
                self.dispatch(action)
            case .Error(let error):
                if let action = self.errorAction(error) {
                    self.dispatch(action)
                }else{
                    print("warning: action observable errored but was not handled: \(error)")
                    break
                }
            case .Completed:
                break
            }
        }
    }()
    
    override var state: State {
        get {
            return _state.value
        }
        set {
            _state.value = newValue
        }
    }
    
    override init(withState initialState: State, middleware: [Middleware], reducer: Reducer) {
        self._state = Variable(initialState)
        super.init(withState: initialState, middleware: middleware, reducer: reducer)
    }
    
    // override this to dispatch an action when an error occurs. By default,
    // error is logged and ignored
    public func errorAction(error: ErrorType) -> Action? {
        return nil
    }
    
    public func asObservable() -> Observable<E> {
        return _state.asObservable()
    }
    
    public func subscribe<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        return asObservable().subscribe(observer)
    }
}

#endif