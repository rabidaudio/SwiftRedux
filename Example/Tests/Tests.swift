// https://github.com/Quick/Quick

import Quick
import Nimble
import SwiftRedux

class TableOfContentsSpec: QuickSpec {
    
    override func spec() {
        
        describe("CombinedReduder") {
            
            it("calls all child reducers"){
                let callReducer = CallCounterReducer<ExampleState,ExampleAction>()
                
                let combined = CombinedReducer<ExampleState,ExampleAction>(
                    callReducer.reduce,
                    callReducer.reduce,
                    callReducer.reduce
                ).combine()
                
                let _ = combined(prevState: ExampleState(x: 0, y: true), action: .NoOp)
                
                expect(callReducer.callCount) == 3
            }
            
            it("passes through an empty set of reducers") {
                let reducer = CombinedReducer<ExampleState,ExampleAction>().combine()
                
                let initialState = ExampleState(x: 0, y: true)
                let newState = reducer(prevState: initialState, action: .NoOp)
                
                expect(newState.x) == initialState.x
                expect(newState.y) == initialState.y
            }
        }
        
        describe("Store") {
            
            it("stores a value"){
                let store = Store<ExampleState,ExampleAction>(
                    withState: ExampleState(x: 0, y: false),
                    middleware: [],
                    reducer: ExampleReducer
                )
                
                expect(store.state.x) == 0
                expect(store.state.y) == false
            }
            
            it("dispatches actions to reducers") {
                let store = Store<ExampleState,ExampleAction>(
                    withState: ExampleState(x: 0, y: false),
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
                
                let store = Store<ExampleState,ExampleAction>(
                    withState: ExampleState(x: 0, y: false),
                    middleware: [m.create],
                    reducer: ExampleReducer
                )
                
                expect(m.createCallCount) == 1
                expect(m.lastStore).to(beIdenticalTo(store))
                expect(m.dispatchCreatorCallCount) == 1
                
                store.dispatch(.NoOp)
                
                store.dispatch(.ToggleY)
                expect(store.state.y) == true
                
                expect(m.createCallCount) == 1
                expect(m.dispatchCreatorCallCount) == 1
                
                store.middleware.append(NoOpMiddleware<ExampleState,ExampleAction>().create)
                
                expect(m.createCallCount) == 2
                expect(m.dispatchCreatorCallCount) == 2
                
                store.dispatch(.ToggleY)
                expect(store.state.y) == false
            }
        }
    }
}
