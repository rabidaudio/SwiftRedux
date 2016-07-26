//
//  PrintMiddleware.swift
//  SwiftRedux
//
//  Created by Charles Julian Knight on 7/25/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

// Example of how to use Middleware
public class PrintMiddleware<S,A> {
    public typealias T = BaseStore<S,A>
    
    let printMethod: (String -> Void)
    
    public init(printMethod: (String->Void) = { print($0) }){
        self.printMethod = printMethod
    }
    
    public func create() -> (store: T) -> T.DispatchCreator {
        return { store in
            return { next in
                return { action in
                    self.printMethod("willDispatch \(action) -> \(store.state)")
                    next(action)
                    self.printMethod("didDispatch \(action) -> \(store.state)")
                }
            }
        }
    }
}