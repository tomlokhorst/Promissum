//
//  PromiseSource.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

// This Notifier is used to implement Promise.map
protocol OriginalSource {
  func registerHandler(handler: () -> Void)
}

public class PromiseSource<Value, Error> : OriginalSource {
  typealias ResultHandler = Result<Value, Error> -> Void
  public var state: State<Value, Error>
  public var warnUnresolvedDeinit: Bool

  private var handlers: [Result<Value, Error> -> Void] = []

  private let originalSource: OriginalSource?

  // MARK: Initializers & deinit

  public convenience init(warnUnresolvedDeinit: Bool = true) {
    self.init(state: .Unresolved, originalSource: nil, warnUnresolvedDeinit: warnUnresolvedDeinit)
  }

  public convenience init(value: Value, warnUnresolvedDeinit: Bool = true) {
    self.init(state: .Resolved(Box(value)), originalSource: nil, warnUnresolvedDeinit: warnUnresolvedDeinit)
  }

  public convenience init(error: Error, warnUnresolvedDeinit: Bool = true) {
    self.init(state: .Rejected(Box(error)), originalSource: nil, warnUnresolvedDeinit: warnUnresolvedDeinit)
  }

  internal init(state: State<Value, Error>, originalSource: OriginalSource?, warnUnresolvedDeinit: Bool) {
    self.originalSource = originalSource
    self.warnUnresolvedDeinit = warnUnresolvedDeinit

    self.state = state
  }

  deinit {
    if warnUnresolvedDeinit {
      switch state {
      case .Unresolved:
        println("PromiseSource.deinit: WARNING: Unresolved PromiseSource deallocated, maybe retain this object?")
      default:
        break
      }
    }
  }


  // MARK: Computed properties

  public var promise: Promise<Value, Error> {
    return Promise(source: self)
  }


  // MARK: Resolve / reject

  public func resolve(value: Value) {

    switch state {
    case .Unresolved:
      state = .Resolved(Box(value))

      executeResultHandlers(.Value(Box(value)))
    default:
      break
    }
  }

  public func reject(error: Error) {

    switch state {
    case .Unresolved:
      state = .Rejected(Box(error))

      executeResultHandlers(.Error(Box(error)))
    default:
      break
    }
  }

  private func executeResultHandlers(result: Result<Value, Error>) {

    // Call all previously scheduled handlers
    callHandlers(result, handlers)

    // Cleanup
    handlers = []
  }

  // MARK: Adding result handlers

  internal func registerHandler(handler: () -> Void) {
    addOrCallResultHandler({ _ in handler() })
  }

  internal func addOrCallResultHandler(handler: Result<Value, Error> -> Void) {

    switch state {
    case .Unresolved(let source):
      // Register with original source
      // Only call handlers after original completes
      if let originalSource = originalSource {
        originalSource.registerHandler {

          switch self.state {
          case .Resolved(let boxed):
            // Value is already available, call handler immediately
            callHandlers(Result.Value(boxed), [handler])

          case .Rejected(let boxed):
            // Error is already available, call handler immediately
            callHandlers(Result.Error(boxed), [handler])

          case .Unresolved(let source):
            assertionFailure("callback should only be called if state is resolved or rejected")
          }
        }
      }
      else {
        // Save handler for later
        handlers.append(handler)
      }

    case .Resolved(let boxed):
      // Value is already available, call handler immediately
      callHandlers(Result.Value(boxed), [handler])

    case .Rejected(let boxed):
      // Error is already available, call handler immediately
      callHandlers(Result.Error(boxed), [handler])
    }
  }
}

internal func callHandlers<T>(arg: T, handlers: [T -> Void]) {
  for handler in handlers {
    handler(arg)
  }
}
