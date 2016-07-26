// https://github.com/Quick/Quick

import Quick
import Nimble
import SwiftRedux
import RxSwift
import PromiseKit

class TableOfContentsSpec: QuickSpec {
    
    override func spec() {
        
        let testState = ExampleState(x: 0, y: false, errorMessage: nil)
        
        describe("CombinedReduder") {
            
            it("calls all child reducers"){
                let callReducer = CallCounterReducer<ExampleState,ExampleAction>()
                
                let combined = CombinedReducer<ExampleState,ExampleAction>(
                    callReducer.reduce,
                    callReducer.reduce,
                    callReducer.reduce
                ).combine()
                
                let newState = combined(prevState: testState, action: .NoOp)
                
                expect(newState.x) == 0
                expect(newState.y).to(beFalse())
                expect(callReducer.callCount) == 3
            }
            
            it("passes through an empty set of reducers") {
                let reducer = CombinedReducer<ExampleState,ExampleAction>().combine()
                
                let initialState = testState
                let newState = reducer(prevState: initialState, action: .NoOp)
                
                expect(newState.x) == initialState.x
                expect(newState.y) == initialState.y
            }
        }
        
        describe("Store") {
            
            it("stores a value"){
                let store = BaseStore<ExampleState,ExampleAction>(
                    withState: testState,
                    middleware: [],
                    reducer: ExampleReducer
                )
                
                expect(store.state.x) == 0
                expect(store.state.y) == false
            }
            
            it("dispatches actions to reducers") {
                let store = BaseStore<ExampleState,ExampleAction>(
                    withState: testState,
                    middleware: [],
                    reducer: ExampleReducer
                )
                
                store.dispatch(.NoOp)
                expect(store.state.x) == 0
                expect(store.state.y) == false
                
                store.dispatch(.ToggleY)
                expect(store.state.x) == 0
                expect(store.state.y) == true
                
                store.dispatch(.SetX(newX: 99))
                expect(store.state.x) == 99
                expect(store.state.y) == true
                
                store.dispatch(.NoOp)
                expect(store.state.x) == 99
                expect(store.state.y) == true
            }
            
        }
        
        describe("Middleware"){
            
            it("should allow the creation of middleware") {
                
                let m = GenericMiddleware<ExampleState,ExampleAction>()
                
                let store = RxStore<ExampleState,ExampleAction>(
                    withState: testState,
                    middleware: [m.create(), m.create(),
                        PrintMiddleware<ExampleState,ExampleAction>().create()
                    ],
                    reducer: ExampleReducer
                )
                
                expect(m.createCallCount) == 2
                expect(m.lastStore).to(beIdenticalTo(store))
                expect(m.dispatchCreatorCallCount) == 2
                
                store.dispatch(.NoOp)
                
                store.dispatch(.ToggleY)
                expect(store.state.y) == true
                
                expect(m.createCallCount) == 2
                expect(m.dispatchCreatorCallCount) == 2
                
                store.middleware.append(NoOpMiddleware<ExampleState,ExampleAction>().create)
                
                expect(m.createCallCount) == 4
                expect(m.dispatchCreatorCallCount) == 4
                
                store.dispatch(.ToggleY)
                expect(store.state.y) == false
            }
        }
        
        describe("HistoryMiddleware") {
            
            it("should allow stepping through time"){
                
                let history = HistoryMiddleware<ExampleState,ExampleAction>(historyLimit: 100, futureLimit: 100) { action -> HistoryAction in
                    switch action {
                    case .Undo:
                        return .Undo(1)
                    case .Redo:
                        return .Redo(1)
                    default:
                        return .Append
                    }
                }
                
                let store = RxStore<ExampleState,ExampleAction>(
                    withState: testState,
                    middleware: [history.create()],
                    reducer: ExampleReducer
                )
                
                expect(history.hasHistory).to(beFalse())
                
                let c = history.historyLimit
                
                for i in 0...c {
                    store.dispatch(.SetX(newX: i))
                }
                
                expect(store.state.x) == 100
                expect(history.hasHistory).to(beTrue())
                expect(history.hasFuture).to(beFalse())
                expect(history.current).notTo(beNil())
                
                for _ in 0...c {
                    store.dispatch(.Undo)
                }
                
                expect(store.state.x) == 0
                expect(history.hasHistory).to(beFalse())
                expect(history.hasFuture).to(beTrue())
                expect(history.current).notTo(beNil())
                
                for _ in 0...c {
                    store.dispatch(.Redo)
                }
                
                expect(store.state.x) == 100
                expect(history.hasHistory).to(beTrue())
                expect(history.hasFuture).to(beFalse())
                expect(history.current).notTo(beNil())
            }
            
            it("should no-op without history") {
                let history = HistoryMiddleware<ExampleState,ExampleAction>(historyLimit: 0) { action -> HistoryAction in
                    switch action {
                    case .Undo:
                        return .Undo(1)
                    case .Redo:
                        return .Redo(1)
                    default:
                        return .Append
                    }
                }
                
                let store = RxStore<ExampleState,ExampleAction>(
                    withState: testState,
                    middleware: [history.create()],
                    reducer: ExampleReducer
                )
                
                expect(history.hasHistory).to(beFalse())
                
                for i in 0..<10 {
                    store.dispatch(.SetX(newX: i))
                    expect(history.hasHistory).to(beFalse())
                    expect(history.current).notTo(beNil())
                }
                
                for _ in 0..<20 {
                    store.dispatch(.Undo)
                    expect(history.hasHistory).to(beFalse())
                    expect(history.current).notTo(beNil())
                }
            }
        }
        
        describe("ObservableStore") {
            
            
            it("should be observable") {
                
                let store = Store<ExampleState,ExampleAction>(withState: testState,
                    middleware: [],
                    reducer: ExampleReducer
                )
                
                var callCount = 0
                
                let dispose = store.subscribe { state in
                    callCount += 1
                    expect(state.x) == store.state.x
                    expect(state.y) == store.state.y
                }
                
                store.dispatch(.NoOp)
                store.dispatch(.ToggleY)
                store.dispatch(.SetX(newX: 5))
                
                expect(callCount) == 3
                expect(store.state.x) == 5
                expect(store.state.y).to(beTrue())
                
                dispose.invalidate()
                
                expect(dispose.valid()).to(beFalse())
            }
        }
        
        describe("RxStore"){
            
            it("should be observable") {
                
                let store = RxStore<ExampleState,ExampleAction>(withState: testState,
                                                              middleware: [],
                                                              reducer: ExampleReducer
                )
                
                var callCount = 0
                
                let disposable = store.subscribeNext { state in
                    callCount += 1
                    expect(state.x) == store.state.x
                    expect(state.y) == store.state.y
                }
                
                store.dispatch(.NoOp)
                store.dispatch(.ToggleY)
                store.dispatch(.SetX(newX: 5))
                
                expect(callCount) == 4
                
                expect(store.state.x) == 5
                expect(store.state.y).to(beTrue())
                
                disposable.dispose()
            }
            
            it("should observe action streams") {
                
                let actions = [
                    ExampleAction.NoOp,
                    ExampleAction.ToggleY,
                    ExampleAction.SetX(newX: 5)
                ].toObservable()
                
                let store = RxStore<ExampleState,ExampleAction>(withState: testState,
                                                                middleware: [],
                                                                reducer: ExampleReducer
                )
                
                let disposeBag = DisposeBag()
                
                var callCount = 0
                
                store.subscribeNext { state in
                    callCount += 1
                    expect(state.x) == store.state.x
                    expect(state.y) == store.state.y
                }.addDisposableTo(disposeBag)
                
                
                actions.subscribe(store.rx_dispatcher).addDisposableTo(disposeBag)
                
                expect(callCount).toEventually(equal(4))
                expect(store.state.x).toEventually(equal(5))
                expect(store.state.y).toEventually(beTrue())
            }
            
            it("should allow async actions") {
                let futureAction = Observable<ExampleAction>.create { subscriber -> Disposable in
                    dispatch_async(dispatch_get_main_queue()) {
                        NSThread.sleepForTimeInterval(0.2)
                        subscriber.onNext(.ToggleY)
                        subscriber.onCompleted()
                    }
                    return NopDisposable.instance
                }
                
                let store = RxStore<ExampleState,ExampleAction>(withState: testState,
                                                                middleware: [],
                                                                reducer: ExampleReducer
                )
                
                let disposeBag = DisposeBag()
                
                var callCount = 0
                
                store.subscribeNext { state in
                    callCount += 1
                    expect(state.x) == store.state.x
                    expect(state.y) == store.state.y
                }.addDisposableTo(disposeBag)
                
                
                futureAction.subscribe(store.rx_dispatcher).addDisposableTo(disposeBag)
                
                expect(callCount).toEventually(equal(2))
                expect(store.state.y).toEventually(beTrue())
            }
            
            it("should allow for custom error actions") {
                let futureAction = Observable<ExampleAction>.create { subscriber -> Disposable in
                    dispatch_async(dispatch_get_main_queue()) {
                        NSThread.sleepForTimeInterval(0.2)
                        subscriber.onError(MyErrorType.ExampleError(message: "some error"))
                    }
                    return NopDisposable.instance
                }
                
                let store = RxStoreWithErrorHandler(
                    withState: testState,
                    reducer: ExampleReducer
                )
                
                let disposeBag = DisposeBag()
                
                var callCount = 0
                
                store.subscribeNext { state in callCount += 1 }.addDisposableTo(disposeBag)
                
                
                futureAction.subscribe(store.rx_dispatcher).addDisposableTo(disposeBag)
                
                expect(callCount).toEventually(equal(2))
                expect(store.state.errorMessage).toEventually(equal("some error"))
            }
        }
        
        describe("PKStore") {
            
            it("should promise future values") {
                
                let store = PKStore<ExampleState,ExampleAction>(withState: testState,
                                                                middleware: [],
                                                                reducer: ExampleReducer
                )
                
                var callCount = 0
                
                let block = { (state: ExampleState) -> Void in
                    callCount += 1
//                    expect(state.x) == 0
//                    expect(state.y) == false
                }
                
                store.promiseNextChange().then { block($0) }
                store.promiseNextChange().then { block($0) }
                
                store.dispatch(.NoOp)
                
                expect(callCount).toEventually(equal(2))
                
                store.promiseNextChange().then { (state: ExampleState) -> Void in
                    callCount += 1
//                    expect(state.x) == 0
//                    expect(state.y) == true
                }
                
                store.dispatch(.ToggleY)
                store.dispatch(.SetX(newX: 5))
                
                expect(callCount).toEventually(equal(3))
                expect(callCount).toNotEventually(beGreaterThan(3))
            }
            
            it("should allow for promised actions") {
                let store = PKStore<ExampleState,ExampleAction>(withState: testState,
                                                                middleware: [],
                                                                reducer: ExampleReducer
                )
                
                store.dispatchAsync(Promise().thenInBackground {
                    return Promise(ExampleAction.ToggleY)
                })
                
                expect(store.state.y).toEventually(beTrue())
            }
            
            it("should allow for custom error actions") {
                let store = PKStoreWithErrorHandler(withState: testState, reducer: ExampleReducer)
                
                store.dispatchAsync(Promise().thenInBackground {
                    return Promise(error: MyErrorType.ExampleError(message: "another error"))
                })
                
                expect(store.state.errorMessage).toNotEventually(beNil())
                expect(store.state.errorMessage!).toEventually(equal("another error"))
            }
        }
    }
}
