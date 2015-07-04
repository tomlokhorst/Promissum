//
//  Promise.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

public let PromissumErrorDomain = "com.nonstrict.Promissum"

public struct Promise<T> {
  private let source: PromiseSource<T>

  // MARK: Initializers

  public init(value: T) {
    self.init(source: PromiseSource(value: value))
  }

  public init(error: NSError) {
    self.init(source: PromiseSource(error: error))
  }

  internal init(source: PromiseSource<T>) {
    self.source = source
  }

  // MARK: Computed properties

  public var value: T? {
    switch source.state {
    case .Resolved(let boxed):
      return boxed.unbox
    default:
      return nil
    }
  }

  public var error: NSError? {
    switch source.state {
    case .Rejected(let error):
      return error
    default:
      return nil
    }
  }

  public var result: Result<T>? {
    switch source.state {
    case .Resolved(let boxed):
      return .Value(boxed)
    case .Rejected(let error):
      return .Error(error)
    default:
      return nil
    }
  }

  // MARK: Attach handlers

  public func then(handler: T -> Void) -> Promise<T> {

    let resultHandler: Result<T> -> Void = { result in
      switch result {
      case .Value(let boxed):
        handler(boxed.unbox)
      case .Error:
        break
      }
    }

    source.addOrCallResultHandler(resultHandler)

    return self
  }

  public func catch(handler: NSError -> Void) -> Promise<T> {

    let resultHandler: Result<T> -> Void = { result in
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

  public func finally(handler: () -> Void) -> Promise<T> {

    let resultHandler: Result<T> -> Void = { _ in
      handler()
    }

    source.addOrCallResultHandler(resultHandler)

    return self
  }

  public func finallyResult(handler: Result<T> -> Void) -> Promise<T> {

    source.addOrCallResultHandler(handler)

    return self
  }


  // MARK: - Value combinators

  public func map<U>(transform: T -> U) -> Promise<U> {
    let resultSource = PromiseSource<U>(state: .Unresolved, originalSource: self.source, warnUnresolvedDeinit: true)

    let handler: Result<T> -> Void = { result in
      switch result {
      case .Value(let boxed):
        let transformed = transform(boxed.unbox)
        resultSource.resolve(transformed)
      case .Error(let error):
        resultSource.reject(error)
      }
    }

    source.addOrCallResultHandler(handler)

    return resultSource.promise
  }

  public func flatMap<U>(transform: T -> Promise<U>) -> Promise<U> {
    let resultSource = PromiseSource<U>()

    let handler: Result<T> -> Void = { result in
      switch result {
      case .Value(let boxed):
        let transformedPromise = transform(boxed.unbox)
        transformedPromise
          .then(resultSource.resolve)
          .catch(resultSource.reject)
      case .Error(let error):
        resultSource.reject(error)
      }
    }

    source.addOrCallResultHandler(handler)

    return resultSource.promise
  }


  // MARK: Error combinators

  public func mapError(transform: NSError -> T) -> Promise<T> {
    let resultSource = PromiseSource<T>(state: .Unresolved, originalSource: self.source, warnUnresolvedDeinit: true)

    let handler: Result<T> -> Void = { result in
      switch result {
      case .Value(let boxed):
        resultSource.resolve(boxed.unbox)
      case .Error(let error):
        let transformed = transform(error)
        resultSource.resolve(transformed)
      }
    }

    source.addOrCallResultHandler(handler)

    return resultSource.promise
  }

  public func flatMapError(transform: NSError -> Promise<T>) -> Promise<T> {
    let resultSource = PromiseSource<T>()

    let handler: Result<T> -> Void = { result in
      switch result {
      case .Value(let boxed):
        resultSource.resolve(boxed.unbox)
      case .Error(let error):
        let transformedPromise = transform(error)
        transformedPromise
          .then(resultSource.resolve)
          .catch(resultSource.reject)
      }
    }

    source.addOrCallResultHandler(handler)

    return resultSource.promise
  }


  // MARK: Result combinators

  public func mapResult(transform: Result<T> -> T) -> Promise<T> {
    let resultSource = PromiseSource<T>(state: .Unresolved, originalSource: self.source, warnUnresolvedDeinit: true)

    let handler: Result<T> -> Void = { result in
      let transformed = transform(result)
      resultSource.resolve(transformed)
    }

    source.addOrCallResultHandler(handler)

    return resultSource.promise
  }

  public func flatMapResult<U>(transform: Result<T> -> Promise<U>) -> Promise<U> {
    let resultSource = PromiseSource<U>()

    let handler: Result<T> -> Void = { result in
      let transformedPromise = transform(result)
      transformedPromise
        .then(resultSource.resolve)
        .catch(resultSource.reject)
    }

    source.addOrCallResultHandler(handler)

    return resultSource.promise
  }
}
