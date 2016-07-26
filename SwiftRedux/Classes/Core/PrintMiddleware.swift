//
//  PrintMiddleware.swift
//  SwiftRedux
//
//  Created by Charles Julian Knight on 7/25/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

// Example of how to use Middleware
public class PrintMiddleware<State,Action> {
    static func create(store: BaseStore<State,Action>) -> BaseStore<State,Action>.DispatchCreator {
        return { next -> BaseStore<State,Action>.Dispatcher in
            return { action in
                print("willDispatch \(action) -> \(store.state)")
                next(action)
                print("didDispatch \(action) -> \(store.state)")
            }
        }
    }
}