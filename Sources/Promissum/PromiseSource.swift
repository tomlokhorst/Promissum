//
//  PromiseSource.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

/**
## Creating Promises

A PromiseSource is used to create a Promise that can be resolved or rejected.

Example:

```
let source = PromiseSource<Int, String>()
let promise = source.promise

// Register handlers with Promise
promise
  .then { value in
    print("The value is: \(value)")
  }
  .trap { error in
    print("The error is: \(error)")
  }

// Resolve the source (will call the Promise handler)
source.resolve(42)
```

Once a PromiseSource is Resolved or Rejected it cannot be changed anymore.
All subsequent calls to `resolve` and `reject` are ignored.

## When to use
A PromiseSource is needed when transforming an asynchronous operation into a Promise.

Example:
```
func someOperationPromise() -> Promise<String, ErrorType> {
  let source = PromiseSource<String, ErrorType>()

  someOperation(callback: { (error, value) in
    if let error = error {
      source.reject(error)
    }
    if let value = value {
      source.resolve(value)
    }
  })

  return promise
}
```

## Memory management
Make sure, when creating a PromiseSource, that someone retains a reference to the source.

In the example above the `someOperation` retains the callback.
But in some cases, often when using weak delegates, the callback is not retained.
In that case, you must manually retain the PromiseSource, or the Promise will never complete.

Note that `PromiseSource.deinit` by default will log a warning when an unresolved PromiseSource is deallocated.

*/
public class PromiseSource<Value, Error> where Error: Swift.Error {
  internal let dispatchKey: DispatchSpecificKey<Void>
  internal let dispatchMethod: DispatchMethod

  /// The current state of the PromiseSource
  private let internalState: PromiseSourceState
  public var state: State<Value, Error> {
    return internalState.readState()
  }

  /// Print a warning on deinit of an unresolved PromiseSource
  public var warnUnresolvedDeinit: Bool

  /// Initialize a new Unresolved PromiseSource
  ///
  /// - parameter warnUnresolvedDeinit: Print a warning on deinit of an unresolved PromiseSource
  public convenience init(dispatch dispatchMethod: DispatchMethod = .unspecified, warnUnresolvedDeinit: Bool = true) {
    self.init(state: .unresolved, dispatchKey: DispatchSpecificKey(), dispatchMethod: dispatchMethod, warnUnresolvedDeinit: warnUnresolvedDeinit)
  }

  internal init(state: State<Value, Error>, dispatchKey: DispatchSpecificKey<Void>, dispatchMethod: DispatchMethod, warnUnresolvedDeinit: Bool) {
    self.internalState = PromiseSourceState(state: state)
    self.dispatchKey = dispatchKey
    self.dispatchMethod = dispatchMethod
    self.warnUnresolvedDeinit = warnUnresolvedDeinit

    if case .queue(let queue) = dispatchMethod {
      queue.setSpecific(key: dispatchKey, value: ())
    }
  }

  deinit {
    if warnUnresolvedDeinit {
      switch state {
      case .unresolved:
        print("PromiseSource.deinit: WARNING: Unresolved PromiseSource deallocated, maybe retain this object?")
      default:
        break
      }
    }

    if case .queue(let queue) = dispatchMethod {
      queue.setSpecific(key: dispatchKey, value: nil)
    }
  }


  // MARK: Computed properties

  /// Promise related to this PromiseSource
  public var promise: Promise<Value, Error> {
    return Promise(source: self)
  }


  // MARK: Resolve / reject

  /// Resolve an Unresolved PromiseSource with supplied value.
  ///
  /// When called on a PromiseSource that is already Resolved or Rejected, the call is ignored.
  public func resolve(_ value: Value) {
    if let action = internalState.resolve(with: .success(value)) {
      callHandlers(action.handlers, with: action.result, dispatchKey: dispatchKey, dispatchMethod: dispatchMethod)
    }
  }


  /// Reject an Unresolved PromiseSource with supplied error.
  ///
  /// When called on a PromiseSource that is already Resolved or Rejected, the call is ignored.
  public func reject(_ error: Error) {
    if let action = internalState.resolve(with: .failure(error)) {
      callHandlers(action.handlers, with: action.result, dispatchKey: dispatchKey, dispatchMethod: dispatchMethod)
    }
  }

  // MARK: Adding result handlers

  internal func addOrCallResultHandler(_ handler: @escaping (Result<Value, Error>) -> Void) {
    if let action = internalState.addHandler(handler) {
      callHandlers(action.handlers, with: action.result, dispatchKey: dispatchKey, dispatchMethod: dispatchMethod)
    }
  }
}

extension PromiseSource {
  typealias ResultHandler = (Result<Value, Error>) -> Void

  fileprivate struct PromiseSourceAction {
    let result: Result<Value, Error>
    let handlers: [ResultHandler]
  }

  fileprivate class PromiseSourceState {
    private let lock = NSLock()
    private var state: State<Value, Error>
    private var handlers: [ResultHandler] = []

    init(state: State<Value, Error>) {
      self.state = state
    }

    internal func readState() -> State<Value, Error> {
      lock.lock(); defer { lock.unlock() }

      return state
    }

    internal func resolve(with result: Result<Value, Error>) -> PromiseSourceAction? {
      lock.lock(); defer { lock.unlock() }

      switch state {
      case .unresolved:
        state = result.state
        let handlersToExecute = handlers
        handlers = []

        return PromiseSourceAction(result: result, handlers: handlersToExecute)
      default:
        return nil
      }
    }

    internal func addHandler(_ handler: @escaping ResultHandler) -> PromiseSourceAction? {
      lock.lock(); defer { lock.unlock() }

      switch state {
      case .unresolved:
        // Save handler for later
        handlers.append(handler)
        return nil

      case .resolved(let value):
        // Value is already available, call handler immediately
        return PromiseSourceAction(result: .success(value), handlers: [handler])

      case .rejected(let error):
        // Error is already available, call handler immediately
        return PromiseSourceAction(result: .failure(error), handlers: [handler])
      }
    }
  }
}

internal func callHandlers<T>(_ handlers: [(T) -> Void], with value: T, dispatchKey: DispatchSpecificKey<Void>, dispatchMethod: DispatchMethod) {

  for handler in handlers {
    switch dispatchMethod {
    case .unspecified:

      // Main queue doesn't guarantee main thread, so this is merely an optimization
      if Thread.isMainThread {
        handler(value)
      }
      else {
        DispatchQueue.main.async {
          handler(value)
        }
      }

    case .synchronous:
      handler(value)

    case .queue(let targetQueue):
      let alreadyOnQueue = DispatchQueue.getSpecific(key: dispatchKey) != nil

      if alreadyOnQueue {
        handler(value)
      }
      else {
        targetQueue.async {
          handler(value)
        }
      }
    }
  }
}
