//
//  PrintMiddleware.swift
//  SwiftRedux
//
//  Created by Charles Julian Knight on 7/25/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

// Example of how to use Middleware
class PrintMiddleware<State,Action> {
    static func create(store: Store<State,Action>) -> Store<State,Action>.DispatchCreator {
        return { next -> Store<State,Action>.Dispatcher in
            return { action in
                print("willDispatch \(action) -> \(store.state)")
                next(action)
                print("didDispatch \(action) -> \(store.state)")
            }
        }
    }
}