//
//  Promise.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

public let PromissumErrorDomain = "com.nonstrict.Promissum"

public class Promise<T> : PromiseNotifier {
  internal(set) var state: State<T>

  internal init(source: PromiseSource<T>) {
    self.state = State.Unresolved(source)
  }

  public init(value: T) {
    state = State<T>.Resolved(Box(value))
  }

  public init(error: NSError) {
    state = State<T>.Rejected(error)
  }

  public func value() -> T? {
    switch state {
    case State<T>.Resolved(let boxed):
      return boxed.unbox
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

  public func result() -> Result<T>? {
    switch state {
    case State<T>.Resolved(let boxed):
      return .Value(boxed)
    case State<T>.Rejected(let error):
      return .Error(error)
    default:
      return nil
    }
  }

  public func then(handler: T -> Void) -> Promise<T> {
    addResolveHandler(handler)

    return self
  }

  public func map<U>(transform: T -> U) -> Promise<U> {
    let source = PromiseSource<U>(originalPromise: self, warnUnresolvedDeinit: true)

    let handler: Result<T> -> Void = { result in
      switch result {
      case .Value(let boxed):
        let transformed = transform(boxed.unbox)
        source.resolve(transformed)
      case .Error(let error):
        source.reject(error)
      }
    }

    addResultHandler(handler)

    return source.promise
  }

  public func flatMap<U>(transform: T -> Promise<U>) -> Promise<U> {
    let source = PromiseSource<U>()

    let handler: Result<T> -> Void = { result in
      switch result {
      case .Value(let boxed):
        let transformedPromise = transform(boxed.unbox)
        transformedPromise
          .then(source.resolve)
          .catch(source.reject)
      case .Error(let error):
        source.reject(error)
      }
    }

    addResultHandler(handler)

    return source.promise
  }

  public func mapError(transform: NSError -> T) -> Promise<T> {
    let source = PromiseSource<T>(originalPromise: self, warnUnresolvedDeinit: true)

    let handler: Result<T> -> Void = { result in
      switch result {
      case .Value(let boxed):
        source.resolve(boxed.unbox)
      case .Error(let error):
        let transformed = transform(error)
        source.resolve(transformed)
      }
    }

    addResultHandler(handler)

    return source.promise
  }

  public func flatMapError(transform: NSError -> Promise<T>) -> Promise<T> {
    let source = PromiseSource<T>()

    let handler: Result<T> -> Void = { result in
      switch result {
      case .Value(let boxed):
        source.resolve(boxed.unbox)
      case .Error(let error):
        let transformedPromise = transform(error)
        transformedPromise
          .then(source.resolve)
          .catch(source.reject)
      }
    }

    addResultHandler(handler)

    return source.promise
  }

  public func catch(handler: NSError -> Void) -> Promise<T> {

    addErrorHandler(handler)

    return self
  }

  public func mapResult(transform: Result<T> -> T) -> Promise<T> {
    let source = PromiseSource<T>()

    let handler: Result<T> -> Void = { result in
      let transformed = transform(result)
      source.resolve(transformed)
    }

    addResultHandler(handler)

    return source.promise
  }

  public func flatMapResult(transform: Result<T> -> Promise<T>) -> Promise<T> {
    let source = PromiseSource<T>()

    let handler: Result<T> -> Void = { result in
      let transformedPromise = transform(result)
      transformedPromise
        .then(source.resolve)
        .catch(source.reject)
    }

    addResultHandler(handler)

    return source.promise
  }

  public func finallyResult(handler: Result<T> -> Void) -> Promise<T> {

    addResultHandler(handler)

    return self
  }

  public func finally(handler: () -> Void) -> Promise<T> {

    addResultHandler({ _ in handler() })

    return self
  }

  public func registerHandler(handler: () -> Void) {
    addResultHandler({ _ in handler() })
  }

  internal func addResultHandler(handler: Result<T> -> Void) {

    switch state {
    case State<T>.Unresolved(let source):
      // Save handler for later
      source.addHander(handler)

    case State<T>.Resolved(let boxed):
      // Value is already available, call handler immediately
      handler(Result.Value(boxed))

    case State<T>.Rejected(let error):
      // Error is already available, call handler immediately
      handler(Result.Error(error))

    }
  }

  // Convinience functions

  private func addResolveHandler(handler: T -> Void) {

    switch state {
    case State<T>.Unresolved(let source):
      // Save handler for later
      let resultHandler: Result<T> -> Void = { result in
        switch result {
        case .Value(let boxed):
          handler(boxed.unbox)
        case .Error:
          break
        }
      }
      source.addHander(resultHandler)

    case State<T>.Resolved(let boxed):
      // Value is already available, call handler immediately
      handler(boxed.unbox)

    case State<T>.Rejected:
      break

    }
  }

  private func addErrorHandler(handler: NSError -> Void) {

    switch state {
    case State<T>.Unresolved(let source):
      // Save handler for later
      let resultHandler: Result<T> -> Void = { result in
        switch result {
        case .Value:
          break
        case .Error(let error):
          handler(error)
        }
      }
      source.addHander(resultHandler)

    case State<T>.Resolved(let boxed):
      break

    case State<T>.Rejected(let error):
      // Error is already available, call handler immediately
      handler(error)
    }
  }
}
