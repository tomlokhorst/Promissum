//
//  PromiseSource.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

public enum Warning {
  case Print
  case FatalError
  case Callback(callstack: [SourceLocation] -> ())
  case DontWarn
}

public struct SourceLocation {
  let file: String
  let line: Int
  let column: Int
  let function: String
  let name: String
}

// This Notifier is used to implement Promise.map
internal protocol OriginalSource : class {
  var originalSource: OriginalSource? { get }
  var sourceLocation: SourceLocation? { get }

  func registerHandler(handler: () -> Void)
}

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
public class PromiseSource<Value, Error> : OriginalSource {
  typealias ResultHandler = Result<Value, Error> -> Void

  private var handlers: [Result<Value, Error> -> Void] = []

  internal weak var originalSource: OriginalSource?
  internal let sourceLocation: SourceLocation?
  private let callstack: [SourceLocation]

  /// The current state of the PromiseSource
  public var state: State<Value, Error>

  /// Print a warning on deinit of an unresolved PromiseSource
  public var warnUnresolvedDeinit: Warning

  // MARK: Initializers & deinit

  /// Initialize a new Unresolved PromiseSource
  ///
  /// - parameter warnUnresolvedDeinit: Print a warning on deinit of an unresolved PromiseSource
  public convenience init(
    warnUnresolvedDeinit: Warning = Warning.Print,
    file: String = __FILE__,
    line: Int = __LINE__,
    column: Int = __COLUMN__,
    function: String = __FUNCTION__)
  {
    let sourceLocation = SourceLocation(
      file: file,
      line: line,
      column: column,
      function: function,
      name: "PromiseSource")

    self.init(
      state: .Unresolved,
      originalSource: nil,
      warnUnresolvedDeinit: warnUnresolvedDeinit,
      sourceLocation: sourceLocation)
  }

  internal init(
    state: State<Value, Error>,
    originalSource: OriginalSource?,
    warnUnresolvedDeinit: Warning,
    sourceLocation: SourceLocation?)
  {
    self.originalSource = originalSource
    self.warnUnresolvedDeinit = warnUnresolvedDeinit

    self.state = state

    self.sourceLocation = sourceLocation
    self.callstack = createCallstack(sourceLocation, originalSource: originalSource)
  }

  deinit {
    guard case .Unresolved = state else { return }
    guard !callstack.isEmpty else { return }

    let message = "Unresolved PromiseSource deallocated, maybe retain this object?\n"
      + "Callstack for deallocated object:\n\(callstackString(callstack))"

    switch warnUnresolvedDeinit {
    case .Print:
      print("WARNING: \(message)")
    case .FatalError:
      fatalError(message)
    case .Callback(let callback):
      callback(callstack)
    case .DontWarn:
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
  public func resolve(value: Value) {

    switch state {
    case .Unresolved:
      state = .Resolved(value)

      executeResultHandlers(.Value(value))
    default:
      break
    }
  }


  /// Reject an Unresolved PromiseSource with supplied error.
  ///
  /// When called on a PromiseSource that is already Resolved or Rejected, the call is ignored.
  public func reject(error: Error) {

    switch state {
    case .Unresolved:
      state = .Rejected(error)

      executeResultHandlers(.Error(error))
    default:
      break
    }
  }

  private func executeResultHandlers(result: Result<Value, Error>) {

    // Call all previously scheduled handlers
    callHandlers(result, handlers: handlers)

    // Cleanup
    handlers = []
  }

  // MARK: Adding result handlers

  internal func registerHandler(handler: () -> Void) {
    addOrCallResultHandler({ _ in handler() })
  }

  internal func addOrCallResultHandler(handler: Result<Value, Error> -> Void) {

    switch state {
    case .Unresolved:
      // Register with original source
      // Only call handlers after original completes
      if let originalSource = originalSource {
        originalSource.registerHandler {

          switch self.state {
          case .Resolved(let value):
            // Value is already available, call handler immediately
            callHandlers(Result.Value(value), handlers: [handler])

          case .Rejected(let error):
            // Error is already available, call handler immediately
            callHandlers(Result.Error(error), handlers: [handler])

          case .Unresolved:
            assertionFailure("callback should only be called if state is resolved or rejected")
          }
        }
      }
      else {
        // Save handler for later
        handlers.append(handler)
      }

    case .Resolved(let value):
      // Value is already available, call handler immediately
      callHandlers(Result.Value(value), handlers: [handler])

    case .Rejected(let error):
      // Error is already available, call handler immediately
      callHandlers(Result.Error(error), handlers: [handler])
    }
  }
}

internal func callHandlers<T>(arg: T, handlers: [T -> Void]) {
  for handler in handlers {
    handler(arg)
  }
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

  return callstack.reverse()
}

private func callstackString(callstack: [SourceLocation]) -> String {
  var lines: [String] = []

  for location in callstack {
    let name = "\(location.name):".stringByPaddingToLength(18, withString: " ", startingAtIndex: 0)
    let str = "\(name)\(location.file):\(location.line):\(location.column) - \(location.function)"

    lines.append(str)
  }

  return lines.joinWithSeparator("\n")
}
