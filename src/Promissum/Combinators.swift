//
//  Combinators.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

public func whenBoth<A, B>(promiseA: Promise<A>, promiseB: Promise<B>) -> Promise<(A, B)> {
  return promiseA.flatMap { valueA in promiseB.map { valueB in (valueA, valueB) } }
}

public func whenAll<T>(promises: [Promise<T>]) -> Promise<[T]> {
  let source = PromiseSource<[T]>()
  var results = promises.map { $0.value() }
  var remaining = promises.count

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
