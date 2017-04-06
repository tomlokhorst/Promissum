//
//  Promise.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

/**
## A future value

_A Promise represents a future value._

To access it's value, register a handler using the `then` method:

```
somePromise.then { value in
  print("The value is: \(value)")
}
```

You can register multiple handlers to access the value multiple times.
To register more multiple handlers, simply call `then` multiple times.
Once available, the value becomes immutable and will never change.

## Failure

A Promise can fail during the computation of the future value.
In that case the error can also be accessed by registering a handler with `trap`:

```
somePromise.trap { error in
  print("The error is: \(error)")
}
```


## States

A Promise is always in one of three states: Unresolved, Resolved, or Rejected.
Once a Promise changes from Unresolved to Resolved/Rejected the appropriate registered handlers are called.
After the Promise has changed from Unresolved, it will always stay either Resolved or Rejected.

It is possible to register for both the value and the error, like so:

```
somePromise
  .then { value in
    print("The value is: \(value)")
  }
  .trap { error in
    print("The error is: \(error)")
  }
```


## Types

The full type `Promise<Value, Error>` has two type arguments, for both the value and the error.

For example; the type `Promise<String, NSError>` represents a future value of type `String` that can potentially fail with a `NSError`.
When creating a Promise yourself, it is recommended to use a custom enum to represent the possible errors cases.

In cases where an error is not applicable, you can use the `NoError` type.


## Transforming a Promise value

Similar to `Array`, a Promise has a `map` method to apply a transform the value of a Promise.

In this example an age (Promise of int) is transformed to a future isAdult boolean:

```
// agePromise has type Promise<Int, NoError>
// isAdultPromise has type Promise<Bool, NoError>
let isAdultPromise = agePromise.map { age in age >= 18 }

```

Again, similar to Arrays, `flatMap` is also available.


## Creating a Promise

To create a Promise, use a `PromiseSoure`.
Note that it is often not needed to create a new Promise.
If an existing Promise is available, transforming that using `map` or `flatMap` is often sufficient.

*/
public struct Promise<Value, Error> {
  private let source: PromiseSource<Value, Error>


  // MARK: Initializers

  /// Initialize a resolved Promise with a value.
  ///
  /// Example: `Promise<Int, NoError>(value: 42)`
  public init(value: Value) {
    self.source = PromiseSource(
      state: .resolved(value),
      dispatchKey: DispatchSpecificKey(),
      dispatchMethod: .unspecified,
      warnUnresolvedDeinit: .dontWarn,
      callstack: Callstack()
    )
  }

  /// Initialize a rejected Promise with an error.
  ///
  /// Example: `Promise<Int, String>(error: "Oops")`
  public init(error: Error) {
    self.source = PromiseSource(
      state: .rejected(error),
      dispatchKey: DispatchSpecificKey(),
      dispatchMethod: .unspecified,
      warnUnresolvedDeinit: .dontWarn,
      callstack: Callstack()
    )
  }

  internal init(source: PromiseSource<Value, Error>) {
    self.source = source
  }


  // MARK: Computed properties

  /// Optionally get the underlying value of this Promise.
  /// Will be `nil` if Promise is Rejected or still Unresolved.
  ///
  /// In most situations it is recommended to register a handler with `then` method instead of directly using this property.
  public var value: Value? {
    if case .resolved(let value) = source.state {
      return value
    }

    return nil
  }

  /// Optionally get the underlying error of this Promise.
  /// Will be `nil` if Promise is Resolved or still Unresolved.
  ///
  /// In most situations it is recommended to register a handler with `trap` method instead of directly using this property.
  public var error: Error? {
    if case .rejected(let error) = source.state {
      return error
    }

    return nil
  }

  /// Optionally get the underlying result of this Promise.
  /// Will be `nil` if Promise still Unresolved.
  ///
  /// In most situations it is recommended to register a handler with `finallyResult` method instead of directly using this property.
  public var result: Result<Value, Error>? {
    switch source.state {
    case .resolved(let boxed):
      return .value(boxed)

    case .rejected(let boxed):
      return .error(boxed)

    default:
      return nil
    }
  }


  // MARK: - Attach handlers

  /// Register a handler to be called when value is available.
  /// The value is passed as an argument to the handler.
  ///
  /// The handler is either called directly, if Promise is already resolved, or at a later point in time when the Promise becomes Resolved.
  ///
  /// Multiple handlers can be registered by calling `then` multiple times.
  ///
  /// ## Execution order
  /// Handlers registered with `then` are called in the order they have been registered.
  /// These are interleaved with the other success handlers registered via `finally` or `map`.
  ///
  /// ## Dispatch queue
  /// The handler is synchronously called on the current thread when Promise is already Resolved.
  /// Or, when Promise is resolved later on, the handler is called synchronously on the thread where `PromiseSource.resolve` is called.
  @discardableResult
  public func then(_ handler: @escaping (Value) -> Void) -> Promise<Value, Error> {

    let resultHandler: (Result<Value, Error>) -> Void = { result in
      switch result {
      case .value(let value):
        handler(value)

      case .error:
        break
      }
    }

    source.addOrCallResultHandler(resultHandler)

    return self
  }

  /// Register a handler to be called when error is available.
  /// The error is passed as an argument to the handler.
  ///
  /// The handler is either called directly, if Promise is already rejected, or at a later point in time when the Promise becomes Rejected.
  ///
  /// Multiple handlers can be registered by calling `trap` multiple times.
  ///
  /// ## Execution order
  /// Handlers registered with `trap` are called in the order they have been registered.
  /// These are interleaved with the other failure handlers registered via `finally` or `mapError`.
  ///
  /// ## Dispatch queue
  /// The handler is synchronously called on the current thread when Promise is already Rejected.
  /// Or, when Promise is rejected later on, the handler is called synchronously on the thread where `PromiseSource.reject` is called.
  @discardableResult
  public func trap(_ handler: @escaping (Error) -> Void) -> Promise<Value, Error> {

    let resultHandler: (Result<Value, Error>) -> Void = { result in
      switch result {
      case .value:
        break

      case .error(let error):
        handler(error)
      }
    }

    source.addOrCallResultHandler(resultHandler)

    return self
  }

  /// Register a handler to be called when Promise is resolved _or_ rejected.
  /// No argument is passed to the handler.
  ///
  /// The handler is either called directly, if Promise is already resolved or rejected,
  /// or at a later point in time when the Promise becomes Resolved or Rejected.
  ///
  /// Multiple handlers can be registered by calling `finally` multiple times.
  ///
  /// ## Execution order
  /// Handlers registered with `finally` are called in the order they have been registered.
  /// These are interleaved with the other result handlers registered via `then` or `trap`.
  ///
  /// ## Dispatch queue
  /// The handler is synchronously called on the current thread when Promise is already Resolved or Rejected.
  /// Or, when Promise is resolved or rejected later on,
  /// the handler is called synchronously on the thread where `PromiseSource.resolve` or `PromiseSource.reject` is called.
  @discardableResult
  public func finally(_ handler: @escaping () -> Void) -> Promise<Value, Error> {

    let resultHandler: (Result<Value, Error>) -> Void = { _ in
      handler()
    }

    source.addOrCallResultHandler(resultHandler)

    return self
  }

  /// Register a handler to be called when Promise is resolved _or_ rejected.
  /// A `Result<Valule, Error>` argument is passed to the handler.
  ///
  /// The handler is either called directly, if Promise is already resolved or rejected,
  /// or at a later point in time when the Promise becomes Resolved or Rejected.
  ///
  /// Multiple handlers can be registered by calling `finally` multiple times.
  ///
  /// ## Execution order
  /// Handlers registered with `finally` are called in the order they have been registered.
  /// These are interleaved with the other result handlers registered via `then` or `trap`.
  ///
  /// ## Dispatch queue
  /// The handler is synchronously called on the current thread when Promise is already Resolved or Rejected.
  /// Or, when Promise is resolved or rejected later on,
  /// the handler is called synchronously on the thread where `PromiseSource.resolve` or `PromiseSource.reject` is called.
  @discardableResult
  public func finallyResult(_ handler: @escaping (Result<Value, Error>) -> Void) -> Promise<Value, Error> {

    source.addOrCallResultHandler(handler)

    return self
  }


  // MARK: Dispatch methods

  /// Returns a Promise that dispatches its handlers on the specified dispatch queue.
  public func dispatch(file: String = #file, line: Int = #line, column: Int = #column, function: String = #function, on queue: DispatchQueue) -> Promise<Value, Error> {
    let key = DispatchSpecificKey<Void>()
    queue.setSpecific(key: key, value: ())

    return dispatch(file: file, line: line, column: column, function: function, on: .queue(queue), dispatchKey: key)
  }
  
  /// Returns a Promise that dispatches its handlers on the main dispatch queue.
  public func dispatchMain(file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) -> Promise<Value, Error> {
    return dispatch(file: file, line: line, column: column, function: function, on: .main)
  }
  
  private func dispatch(file: String = #file, line: Int = #line, column: Int = #column, function: String = #function, on dispatchMethod: DispatchMethod, dispatchKey: DispatchSpecificKey<Void>) -> Promise<Value, Error> {
    
    let sourceLocation = SourceLocation(
      file: file,
      line: line,
      column: column,
      function: function,
      name:  " + map")
    
    let resultSource = PromiseSource<Value, Error>(
      state: .unresolved,
      dispatchKey: dispatchKey,
      dispatchMethod: dispatchMethod,
      warnUnresolvedDeinit: source.warnUnresolvedDeinit,
      callstack: source.callstack.appending(sourceLocation)
    )

    source.addOrCallResultHandler(resultSource.resolveResult)

    return resultSource.promise
  }


  // MARK: - Value combinators

  /// Return a Promise containing the results of mapping `transform` over the value of `self`.
  public func map<NewValue>(file: String = #file, line: Int = #line, column: Int = #column, function: String = #function, _ transform: @escaping (Value) -> NewValue) -> Promise<NewValue, Error> {

    let sourceLocation = SourceLocation(
      file: file,
      line: line,
      column: column,
      function: function,
      name:  " + map")

    let resultSource = PromiseSource<NewValue, Error>(
      state: .unresolved,
      dispatchKey: source.dispatchKey,
      dispatchMethod: source.dispatchMethod,
      warnUnresolvedDeinit: source.warnUnresolvedDeinit,
      callstack: source.callstack.appending(sourceLocation)
    )

    let handler: (Result<Value, Error>) -> Void = { result in
      switch result {
      case .value(let value):
        let transformed = transform(value)
        resultSource.resolve(transformed)

      case .error(let error):
        resultSource.reject(error)
      }
    }

    source.addOrCallResultHandler(handler)

    return resultSource.promise
  }

  /// Returns the flattened result of mapping `transform` over the value of `self`.
  public func flatMap<NewValue>(file: String = #file, line: Int = #line, column: Int = #column, function: String = #function, _ transform: @escaping (Value) -> Promise<NewValue, Error>) -> Promise<NewValue, Error> {

    let sourceLocation = SourceLocation(
      file: file,
      line: line,
      column: column,
      function: function,
      name:  " + flatMap")

    let resultSource = PromiseSource<NewValue, Error>(
      state: .unresolved,
      dispatchKey: source.dispatchKey,
      dispatchMethod: source.dispatchMethod,
      warnUnresolvedDeinit: source.warnUnresolvedDeinit,
      callstack: source.callstack.appending(sourceLocation)
    )

    let handler: (Result<Value, Error>) -> Void = { result in
      switch result {
      case .value(let value):
        let transformedPromise = transform(value)
        transformedPromise
          .then(resultSource.resolve)
          .trap(resultSource.reject)
      case .error(let error):
        resultSource.reject(error)
      }
    }

    source.addOrCallResultHandler(handler)

    return resultSource.promise
  }


  // MARK: Error combinators

  /// Return a Promise containing the results of mapping `transform` over the error of `self`.
  public func mapError<NewError>(file: String = #file, line: Int = #line, column: Int = #column, function: String = #function, _ transform: @escaping (Error) -> NewError) -> Promise<Value, NewError> {

    let sourceLocation = SourceLocation(
      file: file,
      line: line,
      column: column,
      function: function,
      name:  " + mapError")
    
    let resultSource = PromiseSource<Value, NewError>(
      state: .unresolved,
      dispatchKey: source.dispatchKey,
      dispatchMethod: source.dispatchMethod,
      warnUnresolvedDeinit: source.warnUnresolvedDeinit,
      callstack: source.callstack.appending(sourceLocation)
    )

    let handler: (Result<Value, Error>) -> Void = { result in
      switch result {
      case .value(let value):
        resultSource.resolve(value)

      case .error(let error):
        let transformed = transform(error)
        resultSource.reject(transformed)
      }
    }

    source.addOrCallResultHandler(handler)

    return resultSource.promise
  }

  /// Returns the flattened result of mapping `transform` over the error of `self`.
  public func flatMapError<NewError>(file: String = #file, line: Int = #line, column: Int = #column, function: String = #function, _ transform: @escaping (Error) -> Promise<Value, NewError>) -> Promise<Value, NewError> {

    let sourceLocation = SourceLocation(
      file: file,
      line: line,
      column: column,
      function: function,
      name:  " + flatMapError")
    
    let resultSource = PromiseSource<Value, NewError>(
      state: .unresolved,
      dispatchKey: source.dispatchKey,
      dispatchMethod: source.dispatchMethod,
      warnUnresolvedDeinit: source.warnUnresolvedDeinit,
      callstack: source.callstack.appending(sourceLocation)
    )

    let handler: (Result<Value, Error>) -> Void = { result in
      switch result {
      case .value(let value):
        resultSource.resolve(value)
      case .error(let error):
        let transformedPromise = transform(error)
        transformedPromise
          .then(resultSource.resolve)
          .trap(resultSource.reject)
      }
    }

    source.addOrCallResultHandler(handler)

    return resultSource.promise
  }

  // MARK: Result combinators

  /// Return a Promise containing the results of mapping `transform` over the result of `self`.
  public func mapResult<NewValue, NewError>(file: String = #file, line: Int = #line, column: Int = #column, function: String = #function, _ transform: @escaping (Result<Value, Error>) -> Result<NewValue, NewError>) -> Promise<NewValue, NewError> {

    let sourceLocation = SourceLocation(
      file: file,
      line: line,
      column: column,
      function: function,
      name:  " + mapResult")
    
    let resultSource = PromiseSource<NewValue, NewError>(
      state: .unresolved,
      dispatchKey: source.dispatchKey,
      dispatchMethod: source.dispatchMethod,
      warnUnresolvedDeinit: source.warnUnresolvedDeinit,
      callstack: source.callstack.appending(sourceLocation)
    )

    let handler: (Result<Value, Error>) -> Void = { result in
      switch transform(result) {
      case .value(let value):
        resultSource.resolve(value)

      case .error(let error):
        resultSource.reject(error)
      }
    }

    source.addOrCallResultHandler(handler)

    return resultSource.promise
  }

  /// Returns the flattened result of mapping `transform` over the result of `self`.
  public func flatMapResult<NewValue, NewError>(file: String = #file, line: Int = #line, column: Int = #column, function: String = #function, _ transform: @escaping (Result<Value, Error>) -> Promise<NewValue, NewError>) -> Promise<NewValue, NewError> {

    let sourceLocation = SourceLocation(
      file: file,
      line: line,
      column: column,
      function: function,
      name:  " + flatMapResult")
    
    let resultSource = PromiseSource<NewValue, NewError>(
      state: .unresolved,
      dispatchKey: source.dispatchKey,
      dispatchMethod: source.dispatchMethod,
      warnUnresolvedDeinit: source.warnUnresolvedDeinit,
      callstack: source.callstack.appending(sourceLocation)
    )

    let handler: (Result<Value, Error>) -> Void = { result in
      let transformedPromise = transform(result)
      transformedPromise
        .then(resultSource.resolve)
        .trap(resultSource.reject)
    }

    source.addOrCallResultHandler(handler)

    return resultSource.promise
  }
}

// Swift 3 renames
extension Promise {

  @available(*, unavailable, renamed: "dispatch(on:)")
  public func dispatchOn(_ queue: DispatchQueue) -> Promise<Value, Error> {
    fatalError()
  }

}
