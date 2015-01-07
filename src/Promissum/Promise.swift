//
//  Promise.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

public let PromissumErrorDomain = "com.nonstrict.Promissum"

public class Promise<T> {
  private(set) var state = State<T>.Unresolved
  private var resolvedHandlers: [T -> Void] = []
  private var errorHandlers: [NSError -> Void] = []

  internal init() {
  }

  public init(value: T) {
    state = State<T>.Resolved(value)
  }

  public init(error: NSError) {
    state = State<T>.Rejected(error)
  }

  public func map<U>(continuation: T -> U) -> Promise<U> {
    let source = PromiseSource<U>()

    let cont: T -> Void = { val in
      var transformed = continuation(val)
      source.resolve(transformed)
    }

    addResolvedHandler(cont)
    addErrorHandler(source.reject)

    return source.promise
  }

  public func flatMap<U>(continuation: T -> Promise<U>) -> Promise<U> {
    let source = PromiseSource<U>()

    let cont: T -> Void = { val in
      var transformedPromise = continuation(val)
      transformedPromise
        .then(source.resolve)
        .catch(source.reject)
    }

    addResolvedHandler(cont)
    addErrorHandler(source.reject)

    return source.promise
  }

  public func then(handler: T -> Void) -> Promise<T> {
    addResolvedHandler(handler)

    return self
  }

  public func mapError(continuation: NSError -> T) -> Promise<T> {
    let source = PromiseSource<T>()

    let cont: NSError -> Void = { error in
      var transformed = continuation(error)
      source.resolve(transformed)
    }

    addErrorHandler(cont)
    addResolvedHandler(source.resolve)

    return source.promise
  }

  public func flatMapError(continuation: NSError -> Promise<T>) -> Promise<T> {
    let source = PromiseSource<T>()

    let cont: NSError -> Void = { error in
      var transformedPromise = continuation(error)
      transformedPromise
        .then(source.resolve)
        .catch(source.reject)
    }

    addErrorHandler(cont)
    addResolvedHandler(source.resolve)

    return source.promise
  }

  public func catch(continuation: NSError -> Void) -> Promise<T> {
    addErrorHandler(continuation)

    return self
  }

  public func finally(continuation: () -> Void) -> Promise<T> {
    addResolvedHandler({ _ in continuation() })
    addErrorHandler({ _ in continuation() })

    return self
  }

  private func addResolvedHandler(handler: T -> Void) {

    switch state {
    case State<T>.Unresolved:
      // Save handler for later
      resolvedHandlers.append(handler)

    case State<T>.Resolved(let getter):
      // Value is already available, call handler immediately
      let val = getter()
      handler(val)

    case State<T>.Rejected:
      break;
    }
  }

  private func addErrorHandler(handler: NSError -> Void) {

    switch state {
    case State<T>.Unresolved:
      // Save handler for later
      errorHandlers.append(handler)

    case State<T>.Rejected(let error):
      // Error is already available, call handler immediately
      handler(error)

    case State<T>.Resolved:
      break;
    }
  }

  private func executeResolvedHandlers(value: T) {

    // Call all previously scheduled handlers
    for handler in resolvedHandlers {
      handler(value)
    }

    // Cleanup
    resolvedHandlers = []
    errorHandlers = []
  }

  private func executeErrorHandlers(error: NSError) {

    // Call all previously scheduled handlers
    for handler in errorHandlers {
      handler(error)
    }

    // Cleanup
    resolvedHandlers = []
    errorHandlers = []
  }

  public func value() -> T? {
    switch state {
    case State<T>.Resolved(let getter):
      let val = getter()
      return val
    default:
      return nil
    }
  }

  public func error() -> NSError? {
    switch state {
    case State<T>.Rejected(let error):
      return error
    default:
      return nil
    }
  }

  internal func tryResolve(value: T) -> Bool {
    switch state {
    case State<T>.Unresolved:
      state = State<T>.Resolved(value)

      executeResolvedHandlers(value)

      return true
    default:
      return false
    }
  }

  internal func tryReject(error: NSError) -> Bool {

    switch state {
    case State<T>.Unresolved:
      state = State<T>.Rejected(error)

      executeErrorHandlers(error)

      return true
    default:
      return false
    }
  }
}
