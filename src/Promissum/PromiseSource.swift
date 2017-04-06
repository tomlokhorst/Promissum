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
public class PromiseSource<Value, Error> {
  typealias ResultHandler = (Result<Value, Error>) -> Void

  private var handlers: [(Result<Value, Error>) -> Void] = []
  internal let dispatchKey: DispatchSpecificKey<Void>
  internal let dispatchMethod: DispatchMethod

  /// The current state of the PromiseSource
  private(set) public var state: State<Value, Error>

  /// Print a warning on deinit of an unresolved PromiseSource
  public var warnUnresolvedDeinit: Warning
  
  internal weak var originalSource: OriginalSource?
  internal let sourceLocation: SourceLocation?
  private let callstack: [SourceLocation]
  
  // MARK: Initializers & deinit

  internal convenience init(value: Value, warnUnresolvedDeinit: Warning = Warning.print, file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
    
    let sourceLocation = SourceLocation(
      file: file,
      line: line,
      column: column,
      function: function,
      name: "PromiseSource")
    
    self.init(state: .resolved(value), dispatchKey: DispatchSpecificKey(), dispatchMethod: .unspecified, originalSource: nil, warnUnresolvedDeinit: warnUnresolvedDeinit, sourceLocation: sourceLocation)
  }

  internal convenience init(error: Error, warnUnresolvedDeinit: Warning = Warning.print, file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
    
    let sourceLocation = SourceLocation(
      file: file,
      line: line,
      column: column,
      function: function,
      name: "PromiseSource")
    
    self.init(state: .rejected(error), dispatchKey: DispatchSpecificKey(), dispatchMethod: .unspecified, originalSource: nil, warnUnresolvedDeinit: warnUnresolvedDeinit, sourceLocation: sourceLocation)
  }

  /// Initialize a new Unresolved PromiseSource
  ///
  /// - parameter warnUnresolvedDeinit: Print a warning on deinit of an unresolved PromiseSource
  public convenience init(dispatch dispatchMethod: DispatchMethod = .unspecified, warnUnresolvedDeinit: Warning = Warning.print, file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
    
    let sourceLocation = SourceLocation(
      file: file,
      line: line,
      column: column,
      function: function,
      name: "PromiseSource")
    
    self.init(state: .unresolved, dispatchKey: DispatchSpecificKey(), dispatchMethod: dispatchMethod, originalSource: nil, warnUnresolvedDeinit: warnUnresolvedDeinit, sourceLocation: sourceLocation)
  }
  
  internal init(state: State<Value, Error>, dispatchKey: DispatchSpecificKey<Void>, dispatchMethod: DispatchMethod, originalSource: OriginalSource?, warnUnresolvedDeinit: Warning, sourceLocation: SourceLocation) {
    self.state = state
    self.dispatchKey = dispatchKey
    self.dispatchMethod = dispatchMethod
    self.originalSource = originalSource
    self.warnUnresolvedDeinit = warnUnresolvedDeinit
    self.sourceLocation = sourceLocation
    self.callstack = createCallstack(source: sourceLocation, originalSource: originalSource)
  }
  
  deinit {
    guard case .unresolved = state else { return }
    guard !callstack.isEmpty else { return }
    
    let message = "Unresolved PromiseSource deallocated, maybe retain this object?\n"
      + "Callstack for deallocated object:\n\(callstackString(callstack: callstack))"
    
    switch warnUnresolvedDeinit {
    case .print:
      
      print("WARNING: \(message)")
    case .fatalError:
      fatalError(message)
    case .callback(let callback):
      callback(callstack)
    case .dontWarn:
      break
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

    resolveResult(.value(value))
  }


  /// Reject an Unresolved PromiseSource with supplied error.
  ///
  /// When called on a PromiseSource that is already Resolved or Rejected, the call is ignored.
  public func reject(_ error: Error) {

    resolveResult(.error(error))
  }

  internal func resolveResult(_ result: Result<Value, Error>) {

    switch state {
    case .unresolved:
      state = result.state

      executeResultHandlers(result)
    default:
      break
    }
  }

  private func executeResultHandlers(_ result: Result<Value, Error>) {

    // Call all previously scheduled handlers
    callHandlers(result, handlers: handlers, dispatchKey: dispatchKey, dispatchMethod: dispatchMethod)

    // Cleanup
    handlers = []
  }

  // MARK: Adding result handlers

  internal func addOrCallResultHandler(_ handler: @escaping (Result<Value, Error>) -> Void) {

    switch state {
    case .unresolved:
      // Save handler for later
      handlers.append(handler)

    case .resolved(let value):
      // Value is already available, call handler immediately
      callHandlers(Result.value(value), handlers: [handler], dispatchKey: dispatchKey, dispatchMethod: dispatchMethod)

    case .rejected(let error):
      // Error is already available, call handler immediately
      callHandlers(Result.error(error), handlers: [handler], dispatchKey: dispatchKey, dispatchMethod: dispatchMethod)
    }
  }
}

internal func callHandlers<T>(_ value: T, handlers: [(T) -> Void], dispatchKey: DispatchSpecificKey<Void>, dispatchMethod: DispatchMethod) {

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

public enum Warning {
  case print
  case fatalError
  case callback(callstack: ([SourceLocation]) -> ())
  case dontWarn
}

public struct SourceLocation {
  public let file: String
  public let line: Int
  public let column: Int
  public let function: String
  public let name: String
}

internal protocol OriginalSource : class {
  var originalSource: OriginalSource? { get }
  var sourceLocation: SourceLocation? { get }

  func registerHandler(handler: () -> Void)
}

private func createCallstack(source: SourceLocation?, originalSource: OriginalSource?) -> [SourceLocation] {
  guard let sourceLocation = source else { return [] }

  var callstack = [sourceLocation]
  var parent = originalSource

  while parent != nil {
    if let location = parent?.sourceLocation {
      callstack.append(location)
    }

    parent = originalSource?.originalSource
  }

  return callstack.reversed()
}

private func callstackString(callstack: [SourceLocation]) -> String {
  var lines: [String] = []

  for location in callstack {
    let name = "\(location.name):".padding(toLength: 18, withPad: " ", startingAt: 0)
    let str = "\(name)\(location.file):\(location.line):\(location.column) - \(location.function)"

    lines.append(str)
  }

  return lines.joined(separator: "\n")
}
