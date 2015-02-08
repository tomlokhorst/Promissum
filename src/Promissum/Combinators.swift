//
//  Combinators.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

public func flatten<T>(promise: Promise<Promise<T>>) -> Promise<T> {
  let source = PromiseSource<T>()

  promise
    .catch(source.reject)
    .then { p in
      p.catch(source.reject).then(source.resolve)
      return
    }

  return source.promise
}

public func whenBoth<A, B>(promiseA: Promise<A>, promiseB: Promise<B>) -> Promise<(A, B)> {
  return promiseA.flatMap { valueA in promiseB.map { valueB in (valueA, valueB) } }
}

public func whenAll<T>(promises: [Promise<T>]) -> Promise<[T]> {
  let source = PromiseSource<[T]>()
  var results = promises.map { $0.value() }
  var remaining = promises.count

  if remaining == 0 {
    source.resolve([])
  }
  
  for (ix, promise) in enumerate(promises) {

    promise
      .then { value in
        results[ix] = value
        remaining = remaining - 1

        if remaining == 0 {
          source.resolve(results.map { $0! })
        }
    }

    promise
      .catch { error in
        source.reject(error)
    }
  }

  return source.promise
}

public func whenEither<T>(promise1: Promise<T>, promise2: Promise<T>) -> Promise<T> {
  return whenAny([promise1, promise2])
}

public func whenAny<T>(promises: [Promise<T>]) -> Promise<T> {
  let source = PromiseSource<T>()
  var remaining = promises.count

  if remaining == 0 {
    let userInfo = [ NSLocalizedDescriptionKey: "whenAny: empty array of promises provided" ]
    source.reject(NSError(domain: PromissumErrorDomain, code: 0, userInfo: userInfo))
  }

  for promise in promises {

    promise
      .then { value in
        source.resolve(value)
      }

    promise
      .catch { error in
        remaining = remaining - 1

        if remaining == 0 {
          source.reject(error)
        }
      }
  }

  return source.promise
}

public func whenAllFinalized<T>(promises: [Promise<T>]) -> Promise<Void> {
  let source = PromiseSource<Void>()
  var remaining = promises.count

  if remaining == 0 {
    source.resolve()
  }

  for promise in promises {

    promise
      .finally {
        remaining = remaining - 1

        if remaining == 0 {
          source.resolve()
        }
      }
  }

  return source.promise
}

public func whenAnyFinalized<T>(promises: [Promise<T>]) -> Promise<Void> {
  let source = PromiseSource<Void>()
  var remaining = promises.count

  if remaining == 0 {
    let userInfo = [ NSLocalizedDescriptionKey: "whenAnyFinalized: empty array of promises provided" ]
    source.reject(NSError(domain: PromissumErrorDomain, code: 0, userInfo: userInfo))
  }

  for promise in promises {

    promise
      .finally {
        source.resolve()
      }
  }

  return source.promise
}

extension Promise {
  public func void() -> Promise<Void> {
    return self.map { _ in }
  }
}
