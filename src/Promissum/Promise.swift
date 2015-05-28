//
//  Promise.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

public let PromissumErrorDomain = "com.nonstrict.Promissum"

public class Promise<Value, Error> : PromiseNotifier {
  internal(set) var state: State<Value, Error>

  internal init(source: PromiseSource<Value, Error>) {
    self.state = State.Unresolved(source)
  }

  public init(value: Value) {
    state = .Resolved(Box(value))
  }

  public init(error: Error) {
    state = .Rejected(Box(error))
  }

  public func value() -> Value? {
    switch state {
    case State<Value, Error>.Resolved(let boxed):
      return boxed.unbox
    default:
      return nil
    }
  }

  public func error() -> Error? {
    switch state {
    case State<Value, Error>.Rejected(let boxed):
      return boxed.unbox
    default:
      return nil
    }
  }

  public func result() -> Result<Value, Error>? {
    switch state {
    case State<Value, Error>.Resolved(let boxed):
      return .Value(boxed)
    case State<Value, Error>.Rejected(let boxed):
      return .Error(boxed)
    default:
      return nil
    }
  }

  public func then(handler: Value -> Void) -> Promise<Value, Error> {
    addResolveHandler(handler)

    return self
  }

  public func map<NewValue>(transform: Value -> NewValue) -> Promise<NewValue, Error> {
    let source = PromiseSource<NewValue, Error>(originalPromise: self, warnUnresolvedDeinit: true)

    let handler: Result<Value, Error> -> Void = { result in
      switch result {
      case .Value(let boxed):
        let transformed = transform(boxed.unbox)
        source.resolve(transformed)
      case .Error(let boxed):
        source.reject(boxed.unbox)
      }
    }

    addResultHandler(handler)

    return source.promise
  }

  public func flatMap<NewValue>(transform: Value -> Promise<NewValue, Error>) -> Promise<NewValue, Error> {
    let source = PromiseSource<NewValue, Error>()

    let handler: Result<Value, Error> -> Void = { result in
      switch result {
      case .Value(let boxed):
        let transformedPromise = transform(boxed.unbox)
        transformedPromise
          .then(source.resolve)
          .catch(source.reject)
      case .Error(let boxed):
        source.reject(boxed.unbox)
      }
    }

    addResultHandler(handler)

    return source.promise
  }

  public func mapError<NewError>(transform: Error -> NewError) -> Promise<Value, NewError> {
    let source = PromiseSource<Value, NewError>(originalPromise: self, warnUnresolvedDeinit: true)

    let handler: Result<Value, Error> -> Void = { result in
      switch result {
      case .Value(let boxed):
        source.resolve(boxed.unbox)
      case .Error(let boxed):
        let transformed = transform(boxed.unbox)
        source.reject(transformed)
      }
    }

    addResultHandler(handler)

    return source.promise
  }

  public func flatMapError(transform: Error -> Promise<Value, Error>) -> Promise<Value, Error> {
    let source = PromiseSource<Value, Error>()

    let handler: Result<Value, Error> -> Void = { result in
      switch result {
      case .Value(let boxed):
        source.resolve(boxed.unbox)
      case .Error(let boxed):
        let transformedPromise = transform(boxed.unbox)
        transformedPromise
          .then(source.resolve)
          .catch(source.reject)
      }
    }

    addResultHandler(handler)

    return source.promise
  }

  public func catch(handler: Error -> Void) -> Promise<Value, Error> {

    addErrorHandler(handler)

    return self
  }

  public func mapResult(transform: Result<Value, Error> -> Result<Value, Error>) -> Promise<Value, Error> {
    let source = PromiseSource<Value, Error>()

    let handler: Result<Value, Error> -> Void = { result in
      switch transform(result) {
      case .Value(let boxed):
        source.resolve(boxed.unbox)
      case .Error(let boxed):
        source.reject(boxed.unbox)
      }
    }

    addResultHandler(handler)

    return source.promise
  }

  public func flatMapResult<NewValue, NewError>(transform: Result<Value, Error> -> Promise<NewValue, NewError>) -> Promise<NewValue, NewError> {
    let source = PromiseSource<NewValue, NewError>()

    let handler: Result<Value, Error> -> Void = { result in
      let transformedPromise = transform(result)
      transformedPromise
        .then(source.resolve)
        .catch(source.reject)
    }

    addResultHandler(handler)

    return source.promise
  }

  public func finallyResult(handler: Result<Value, Error> -> Void) -> Promise<Value, Error> {

    addResultHandler(handler)

    return self
  }

  public func finally(handler: () -> Void) -> Promise<Value, Error> {

    addResultHandler({ _ in handler() })

    return self
  }

  public func registerHandler(handler: () -> Void) {
    addResultHandler({ _ in handler() })
  }

  internal func addResultHandler(handler: Result<Value, Error> -> Void) {

    switch state {
    case State<Value, Error>.Unresolved(let source):
      // Save handler for later
      source.addHander(handler)

    case State<Value, Error>.Resolved(let boxed):
      // Value is already available, call handler immediately
      handler(Result.Value(boxed))

    case State<Value, Error>.Rejected(let boxed):
      // Error is already available, call handler immediately
      handler(Result.Error(boxed))

    }
  }

  // Convinience functions

  private func addResolveHandler(handler: Value -> Void) {

    switch state {
    case State<Value, Error>.Unresolved(let source):
      // Save handler for later
      let resultHandler: Result<Value, Error> -> Void = { result in
        switch result {
        case .Value(let boxed):
          handler(boxed.unbox)
        case .Error:
          break
        }
      }
      source.addHander(resultHandler)

    case State<Value, Error>.Resolved(let boxed):
      // Value is already available, call handler immediately
      handler(boxed.unbox)

    case State<Value, Error>.Rejected:
      break

    }
  }

  private func addErrorHandler(handler: Error -> Void) {

    switch state {
    case State<Value, Error>.Unresolved(let source):
      // Save handler for later
      let resultHandler: Result<Value, Error> -> Void = { result in
        switch result {
        case .Value:
          break
        case .Error(let boxed):
          handler(boxed.unbox)
        }
      }
      source.addHander(resultHandler)

    case State<Value, Error>.Resolved(let boxed):
      break

    case State<Value, Error>.Rejected(let boxed):
      // Error is already available, call handler immediately
      handler(boxed.unbox)
    }
  }
}
