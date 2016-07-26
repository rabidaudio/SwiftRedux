# SwiftRedux

[![CI Status](http://img.shields.io/travis/Charles Julian Knight/SwiftRedux.svg?style=flat)](https://travis-ci.org/Charles Julian Knight/SwiftRedux)
[![Version](https://img.shields.io/cocoapods/v/SwiftRedux.svg?style=flat)](http://cocoapods.org/pods/SwiftRedux)
[![License](https://img.shields.io/cocoapods/l/SwiftRedux.svg?style=flat)](http://cocoapods.org/pods/SwiftRedux)
[![Platform](https://img.shields.io/cocoapods/p/SwiftRedux.svg?style=flat)](http://cocoapods.org/pods/SwiftRedux)

An implementation of [Redux](https://github.com/reactjs/redux) (the Flux-like state container)
in Swift. Supports middleware, as well as combining reducers using `CombinedReducer(...).combine()`.
Any object can be used for your State and Action objects. However, it is recommended to use structs
and enums, respectively, for these objects. This allows you to not worry about accidentally mutating
state (Swift passes struct by value rather than reference) and makes passing action data easy (using
enum tuples).

By default, it ships with a `BaseStore` object which can't be subscribed to by views. There are a few
options included in this library:

- [Observable-Swift](https://github.com/slazyk/Observable-Swift) - Simple property-observing library
- [RxSwift](https://github.com/ReactiveX/RxSwift) - ReactiveX Observable Pattern implementation. Similar
to rx-redux, it allows stores to act as an observer for Actions and an Observable for State

You probably don't want all of these, so it is recommended to use one of the subspecs. See [Installation](#Installation).

## Example

Start by defining your Actions, State, and transitions

```swift
// Define your Actions
enum VisibilityFilter: String {
    case ShowAll, ShowCompleted, ShowActive
}
enum MyAction {
    case AddTODO(text: String)
    case RemoveTODO(index: Int)
    case ToggleTODO(index: Int)
    case SetVisibilityFilter(filter: VisibilityFilter)
}

// Define your State object

class TODO {
    var text: String
    var completed = false

    init(text: String){
        self.text = text
    }

    func toggle(){
        completed = !completed
    }
}

struct MyState {
    var filter: VisibilityFilter
    var todos: [TODO]
}
```

Next, create a reducer (just a function/closure). Remember: [DO NOT produce side effects, make async calls, or use impure functions like `NSDate()`](http://redux.js.org/docs/basics/Reducers.html#handling-actions)

```swift
// To break your reducer into sub reducers, use CombinedReducer(...).combine()
class TODOReducer {
    static func reduce(prevState: AppState, action: AppAction) -> AppState {
      var newState = prevState // prevState is passed by value because it is a struct so no fear of mutation
      switch action {
      case .SetVisibilityFilter(let filter):
          newState.filter = filter
      case .AddTODO(let text):
          newState.todos.append(TODO(text: text))
      case .RemoveTODO(let index):
          newState.todos.removeAtIndex(index)
      case .ToggleTODO(let index):
          newState.todos[index].toggle()
      default:
          break
      return newState
    }
}
```

Then create a Store. There are different implementations depending on if/how you want your views to subscribe to changes.

```swift
let initialState = MyState(filter: .ShowAll, todos: [])

// Base Store - no subscription
let baseStore = BaseStore<MyState,MyAction>(withState: initialState, middleware: [], reducer: TODOReducer.reduce)
baseStore.dispatch(.AddTODO(text: "learn SwiftRedux"))
baseStore.state.todos.first!.text // "learn SwiftRedux"

// Observable-Swift - simple value observation
let obStore = Store<MyState,MyAction>(withState: initialState, middleware: [], reducer: TODOReducer.reduce)
let disposableRef = obStore.subscribe { state in
    // called at each dispatch
}
obStore.dispatch(.SetVisibilityFilter(filter: .ShowCompleted))
disposableRef.invalidate() // clean up subscription after

// RxSwift - Reactive Extensions
let rxStore = RxStore<MyState,MyAction>(withState: initialState, middleware: [], reducer: TODOReducer.reduce)
let actions = [MyAction.AddTODO(text: "learn Rx"), MyAction.ToggleTODO(index: 0), MyAction.RemoveTODO(index: 0)].toObservable()
let disposeBag = DisposeBag()
actions.subscribe(rxStore.rx_dispatcher).addDisposableTo(disposeBag) // pipe actions into store. You can use `bindTo` instead of `subscribe` if you are using RxCocoa
actions.subscribeNext { state in
    // called at each dispatch
}.addDisposableTo(disposeBag)
```

If you want to cause errors thrown by action observables to emit another action, you can subclass `RxStore` and override `errorAction`, which
will dispatch the given error for you.

```swift
class MyStore: RxStore<MyState,MyAction> {
    override func errorAction(error: ErrorType) -> Action? {
      return MyAction.ErrorAction(payload: error, error: true)
    }
}
```

It has support for Middleware as well.

```swift
class SomeMiddleware<S,A> {
    static func create(store: BaseStore<S,A>) -> BaseStore<S,A>.DispatchCreator {
        return { next -> BaseStore<S,A>.Dispatcher in
            return { action in
                // ... do something ...
                next(action) // be sure to pass on to the next dispatcher
            }
        }
    }
}
// usage: middleware = [SomeMiddleware.create]
```

## Requirements

## Installation

SwiftRedux is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
# pod "SwiftRedux" # will import all stores, which is probably not what you want
pod "SwiftRedux/Observable-Swift" # for the simple Observable case
pod "SwiftRedux/RxSwift" # for the Rx-based implementation
```

## License

SwiftRedux is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
