//
//  HistoryMiddleware.swift
//  Pods
//
//  Created by Charles Julian Knight on 7/26/16.
//
//

import Foundation

public enum HistoryAction {
    case NoOp
    case Append
    case Undo(Int)
    case Redo(Int)
    case ClearHistory
    case ClearFuture
}

public protocol Duplicable {
    func duplicate() -> Self
}

public class HistoryMiddleware<S:Duplicable,A> {
    public typealias T = BaseStore<S,A>
    
    public let historyLimit: Int
    public let futureLimit: Int
    let actionMapper: (A->HistoryAction)
    
    public private(set) var history = [S]()
    public private(set) var future = [S]()
    public private(set) var current: S? = nil
    
    public init(historyLimit: Int = 1, futureLimit: Int = 0, actionMapper: (A -> HistoryAction)){
        self.historyLimit = historyLimit
        self.futureLimit = futureLimit
        self.actionMapper = actionMapper
    }
    
    public var hasHistory: Bool {
        return !history.isEmpty
    }
    
    public var hasFuture: Bool {
        return !future.isEmpty
    }
    
    func undo(){
        if let newState = history.popLast() {
            if let current = current?.duplicate() {
                future.append(current)
                while future.count > futureLimit {
                    future.removeFirst()
                }
            }
            current = newState
        }
    }
    
    func redo(){
        if let newState = future.popLast() {
            if let current = current?.duplicate() {
                history.append(current)
                while history.count > historyLimit {
                    history.removeFirst()
                }
            }
            current = newState
        }
    }
    
    func add(item: S){
        future.removeAll()
        if let current = current?.duplicate() {
            history.append(current)
            while history.count > historyLimit {
                history.removeFirst()
            }
        }
        current = item
    }
    
    func onChange() {
        
    }
    
    public func create() -> (store: T) -> T.DispatchCreator {
        return { store in
            self.current = store.state
            self.future.removeAll()
            self.history.removeAll()
            return { next in
                return { action in
                    switch self.actionMapper(action) {
                    case .NoOp:
                        next(action)
                        return
                    case .Append:
                        next(action)
                        self.add(store.state.duplicate())
                    case .Undo(let count):
                        count.times { self.undo() }
                        if let state = self.current {
                            store.state = state
                        }
                    case .Redo(let count):
                        count.times { self.redo() }
                        if let state = self.current {
                            store.state = state
                        }
                    case .ClearHistory:
                        self.history.removeAll()
                    case .ClearFuture:
                        self.history.removeAll()
                    }
                    self.onChange()
                }
            }
        }
    }
}

extension Int {
    private func times(block: (Void -> Void)){
        for i in 0..<self {
            block()
        }
    }
}