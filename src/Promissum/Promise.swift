//
//  Promise.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

public let PromissumErrorDomain = "com.nonstrict.Promissum"

public class Promise<Value, Error> {
  private let source: PromiseSource<Value, Error>


  // MARK: Initializers

  public convenience init(value: Value) {
    self.init(source: PromiseSource(value: value))
  }

  public convenience init(error: Error) {
    self.init(source: PromiseSource(error: error))
  }

  internal init(source: PromiseSource<Value, Error>) {
    self.source = source
  }


  // MARK: Computed properties

  public var value: Value? {
    switch source.state {
    case .Resolved(let value):
      return value
    default:
      return nil
    }
  }

  public var error: Error? {
    switch source.state {
    case .Rejected(let error):
      return error
    default:
      return nil
    }
  }

  public var result: Result<Value, Error>? {
    switch source.state {
    case .Resolved(let boxed):
      return .Value(boxed)
    case .Rejected(let boxed):
      return .Error(boxed)
    default:
      return nil
    }
  }


  // MARK: Attach handlers

  public func then(handler: Value -> Void) -> Promise<Value, Error> {

    let resultHandler: Result<Value, Error> -> Void = { result in
      switch result {
      case .Value(let value):
        handler(value)
      case .Error:
        break
      }
    }

    source.addOrCallResultHandler(resultHandler)

    return self
  }

  public func trap(handler: Error -> Void) -> Promise<Value, Error> {

    let resultHandler: Result<Value, Error> -> Void = { result in
      switch result {
      case .Value:
        break
      case .Error(let error):
        handler(error)
      }
    }

    source.addOrCallResultHandler(resultHandler)

    return self
  }

  public func finally(handler: () -> Void) -> Promise<Value, Error> {

    let resultHandler: Result<Value, Error> -> Void = { _ in
      handler()
    }

    source.addOrCallResultHandler(resultHandler)

    return self
  }

  public func finallyResult(handler: Result<Value, Error> -> Void) -> Promise<Value, Error> {

    source.addOrCallResultHandler(handler)

    return self
  }


  // MARK: - Value combinators

  public func map<NewValue>(transform: Value -> NewValue) -> Promise<NewValue, Error> {
    let resultSource = PromiseSource<NewValue, Error>(state: .Unresolved, originalSource: self.source, warnUnresolvedDeinit: true)

    let handler: Result<Value, Error> -> Void = { result in
      switch result {
      case .Value(let value):
        let transformed = transform(value)
        resultSource.resolve(transformed)
      case .Error(let error):
        resultSource.reject(error)
      }
    }

    source.addOrCallResultHandler(handler)

    return resultSource.promise
  }

  public func flatMap<NewValue>(transform: Value -> Promise<NewValue, Error>) -> Promise<NewValue, Error> {
    let resultSource = PromiseSource<NewValue, Error>()

    let handler: Result<Value, Error> -> Void = { result in
      switch result {
      case .Value(let value):
        let transformedPromise = transform(value)
        transformedPromise
          .then(resultSource.resolve)
          .trap(resultSource.reject)
      case .Error(let error):
        resultSource.reject(error)
      }
    }

    source.addOrCallResultHandler(handler)

    return resultSource.promise
  }


  // MARK: Error combinators

  public func mapError<NewError>(transform: Error -> NewError) -> Promise<Value, NewError> {
    let resultSource = PromiseSource<Value, NewError>(state: .Unresolved, originalSource: self.source, warnUnresolvedDeinit: true)

    let handler: Result<Value, Error> -> Void = { result in
      switch result {
      case .Value(let value):
        resultSource.resolve(value)
      case .Error(let error):
        let transformed = transform(error)
        resultSource.reject(transformed)
      }
    }

    source.addOrCallResultHandler(handler)

    return resultSource.promise
  }

  public func flatMapError(transform: Error -> Promise<Value, Error>) -> Promise<Value, Error> {
    let resultSource = PromiseSource<Value, Error>()

    let handler: Result<Value, Error> -> Void = { result in
      switch result {
      case .Value(let value):
        resultSource.resolve(value)
      case .Error(let error):
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

  public func mapResult(transform: Result<Value, Error> -> Result<Value, Error>) -> Promise<Value, Error> {
    let resultSource = PromiseSource<Value, Error>(state: .Unresolved, originalSource: self.source, warnUnresolvedDeinit: true)

    let handler: Result<Value, Error> -> Void = { result in
      switch transform(result) {
      case .Value(let value):
        resultSource.resolve(value)
      case .Error(let error):
        resultSource.reject(error)
      }
    }

    source.addOrCallResultHandler(handler)

    return resultSource.promise
  }

  public func flatMapResult<NewValue, NewError>(transform: Result<Value, Error> -> Promise<NewValue, NewError>) -> Promise<NewValue, NewError> {
    let resultSource = PromiseSource<NewValue, NewError>()

    let handler: Result<Value, Error> -> Void = { result in
      let transformedPromise = transform(result)
      transformedPromise
        .then(resultSource.resolve)
        .trap(resultSource.reject)
    }

    source.addOrCallResultHandler(handler)

    return resultSource.promise
  }
}
