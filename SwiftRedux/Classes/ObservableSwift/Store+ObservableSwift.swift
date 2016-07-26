//
//  Store+ObservableSwift.swift
//  SwiftRedux
//
//  Created by Charles Julian Knight on 7/25/16.
//  Copyright © 2016 Charles Julian Knight. All rights reserved.
//
    
import Foundation
import Observable

//Store which uses Observable-Swift for observation
public class Store<State,Action>: BaseStore<State,Action> {
    public typealias Subscriber = State -> ()
    
    private var _state: Observable<State>
    
    override public init(withState initialState: State, middleware: [Middleware], reducer: Reducer) {
        self._state = Observable(initialState)
        super.init(withState: initialState, middleware: middleware, reducer: reducer)
    }
    
    override public var state: State {
        get {
            return _state.value
        }
        set {
            _state <- newValue
        }
    }
    
    public func subscribe(subscriber: Subscriber) -> EventSubscription<ValueChange<State>> {
        return self._state.afterChange += subscriber
    }
}