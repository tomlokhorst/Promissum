//
//  Combinators.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

public func flatten<Value, Error>(promise: Promise<Promise<Value, Error>, Error>) -> Promise<Value, Error> {
  let source = PromiseSource<Value, Error>()

  promise
    .catch(source.reject)
    .then { p in
      p.catch(source.reject).then(source.resolve)
      return
    }

  return source.promise
}

public func whenBoth<A, B, Error>(promiseA: Promise<A, Error>, promiseB: Promise<B, Error>) -> Promise<(A, B), Error> {
  return promiseA.flatMap { valueA in promiseB.map { valueB in (valueA, valueB) } }
}

public func whenAll<Value, Error>(promises: [Promise<Value, Error>]) -> Promise<[Value], Error> {
  let source = PromiseSource<[Value], Error>()
  var results = promises.map { $0.value }
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

public func whenEither<Value, Error>(promise1: Promise<Value, Error>, promise2: Promise<Value, Error>) -> Promise<Value, Error> {
  return whenAny([promise1, promise2])
}

public func whenAny<Value, Error>(promises: [Promise<Value, Error>]) -> Promise<Value, Error> {
  let source = PromiseSource<Value, Error>()
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

public func whenAllFinalized<Value, Error>(promises: [Promise<Value, Error>]) -> Promise<Void, NoError> {
  let source = PromiseSource<Void, NoError>()
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

public func whenAnyFinalized<Value, Error>(promises: [Promise<Value, Error>]) -> Promise<Void, NoError> {
  let source = PromiseSource<Void, NoError>()
  var remaining = promises.count

  for promise in promises {

    promise
      .finally {
        source.resolve()
      }
  }

  return source.promise
}

extension Promise {
  public func void() -> Promise<Void, Error> {
    return self.map { _ in }
  }
}
