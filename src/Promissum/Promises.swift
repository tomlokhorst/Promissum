//
//  Promises.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

public class Promises {

  public class func whenBoth<A, B>(promiseA: Promise<A>, promiseB: Promise<B>) -> Promise<(A, B)> {
    return promiseA.flatMap { valueA in promiseB.map { valueB in (valueA, valueB) } }
  }

  public class func whenAll<T>(promises: [Promise<T>]) -> Promise<[T]> {
    let source = PromiseSource<[T]>()
    var results = promises.map { $0.value() }
    var remaining = promises.count

    for (ix, promise) in enumerate(promises) {

      promise
        .thenVoid { value in
          results[ix] = value
          remaining = remaining - 1

          if remaining == 0 {
            source.resolve(results.map { $0! })
          }
      }

      promise
        .catchVoid { error in
          source.reject(error)
      }
    }

    return source.promise
  }

  // TODO: whenEither / whenAny
}
