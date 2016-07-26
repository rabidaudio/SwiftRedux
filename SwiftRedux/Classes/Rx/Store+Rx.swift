//
//  Store+Rx.swift
//  SwiftRedux
//
//  Created by Charles Julian Knight on 7/25/16.
//  Copyright © 2016 Charles Julian Knight. All rights reserved.
//

import Foundation
import RxSwift

// Store which observes actions and whose state is observable
public class RxStore<State,Action>: BaseStore<State,Action>, ObservableType {
    public typealias E = State
    
    private let _state: Variable<State>
    
    lazy public private(set) var rx_dispatcher: AnyObserver<Action> = {
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
    
    override public init(withState initialState: State, middleware: [Middleware], reducer: Reducer) {
        self._state = Variable(initialState)
        super.init(withState: initialState, middleware: middleware, reducer: reducer)
    }
    
    override public var state: State {
        get {
            return _state.value
        }
        set {
            _state.value = newValue
        }
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


public class RxHistoryMiddleware<S:Duplicable,A>: HistoryMiddleware<S,A> {
    
    public let historySize: Variable<Int>
    public let futureSize: Variable<Int>
    
    public let canUndo: Observable<Bool>
    public let canRedo: Observable<Bool>
    
    override public init(historyLimit: Int = 1, futureLimit: Int = 0, actionMapper: (A -> HistoryAction)) {
        historySize = Variable(0)
        futureSize = Variable(0)
        canUndo = historySize.asObservable().map { $0 > 0 }
        canRedo = futureSize.asObservable().map { $0 > 0 }
        super.init(historyLimit: historyLimit, futureLimit: futureLimit, actionMapper: actionMapper)
    }
    
    override func onChange() {
        historySize.value = history.count
        futureSize.value = future.count
    }
    
}