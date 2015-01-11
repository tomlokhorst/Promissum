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
  internal(set) var state: State<T>

  internal init(source: PromiseSource<T>) {
    self.state = State.Unresolved(source)
  }

  public init(value: T) {
    state = State<T>.Resolved(value)
  }

  public init(error: NSError) {
    state = State<T>.Rejected(error)
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

  public func then(handler: T -> Void) -> Promise<T> {
    addResolvedHandler(handler)

    return self
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

  private func addResolvedHandler(handler: T -> Void) {

    switch state {
    case let State<T>.Unresolved(source):
      // Save handler for later
      source.resolvedHandlers.append(handler)

    case State<T>.Resolved(let getter):
      // Value is already available, call handler immediately
      let value = getter()
      callHandlers(value, [handler])

    case State<T>.Rejected:
      break;
    }
  }

  private func addErrorHandler(handler: NSError -> Void) {

    switch state {
    case let State<T>.Unresolved(source):
      // Save handler for later
      source.errorHandlers.append(handler)

    case State<T>.Rejected(let error):
      // Error is already available, call handler immediately
      callHandlers(error, [handler])

    case State<T>.Resolved:
      break;
    }
  }
}
