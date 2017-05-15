//
//  Delay.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-01-12.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation

/// Wrapper around `dispatch_after`, with a seconds parameter.
public func delay(_ seconds: TimeInterval, queue: DispatchQueue! = DispatchQueue.main, execute: @escaping () -> Void) {
  let when = DispatchTime.now() + seconds

  queue.asyncAfter(deadline: when, execute: execute)
}

/// Create a Promise that resolves with the specified value after the specified number of seconds.
public func delayPromise<Value, Error>(_ seconds: TimeInterval, value: Value, queue: DispatchQueue! = DispatchQueue.main) -> Promise<Value, Error> {
  let source = PromiseSource<Value, Error>()

  delay(seconds, queue: queue) {
    source.resolve(value)
  }

  return source.promise
}

/// Create a Promise that rejects with the specified error after the specified number of seconds.
public func delayErrorPromise<Value, Error>(_ seconds: TimeInterval, error: Error, queue: DispatchQueue! = DispatchQueue.main) -> Promise<Value, Error> {
  let source = PromiseSource<Value, Error>()

  delay(seconds, queue: queue) {
    source.reject(error)
  }

  return source.promise
}

/// Create a Promise that resolves after the specified number of seconds.
public func delayPromise<Error>(_ seconds: TimeInterval, queue: DispatchQueue! = DispatchQueue.main) -> Promise<Void, Error> {
  return delayPromise(seconds, value: (), queue: queue)
}

extension Promise {

  /// Return a Promise with the resolve or reject delayed by the specified number of seconds.
  public func delay(_ seconds: TimeInterval) -> Promise<Value, Error> {
    return self
      .flatMap { value in
        return delayPromise(seconds).map { value }
      }
      .flatMapError { error in
        return delayPromise(seconds).flatMap { Promise(error: error) }
      }
  }
}
