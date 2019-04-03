//
//  Delay.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-01-12.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation

/// Wrapper around `dispatch_after`, with a seconds parameter.
@available(*, deprecated, message: "Use DispatchQueue.main.asyncAfter instead")
public func delay(_ seconds: TimeInterval, queue: DispatchQueue! = DispatchQueue.main, execute: @escaping () -> Void) {
  let when = DispatchTime.now() + seconds

  queue.asyncAfter(deadline: when, execute: execute)
}

/// Create a Promise that resolves with the specified value after the specified number of seconds.
@available(*, deprecated, message: "Use Promise(value: value).delay(seconds) instead")
public func delayPromise<Value, Error>(_ seconds: TimeInterval, value: Value, queue: DispatchQueue! = DispatchQueue.main) -> Promise<Value, Error> {
  let source = PromiseSource<Value, Error>()

  queue.asyncAfter(deadline: .now() + seconds) {
    source.resolve(value)
  }

  return source.promise
}

/// Create a Promise that rejects with the specified error after the specified number of seconds.
@available(*, deprecated, message: "Use Promise(error: error).delay(seconds) instead")
public func delayErrorPromise<Value, Error>(_ seconds: TimeInterval, error: Error, queue: DispatchQueue! = DispatchQueue.main) -> Promise<Value, Error> {
  let source = PromiseSource<Value, Error>()

  queue.asyncAfter(deadline: .now() + seconds) {
    source.reject(error)
  }

  return source.promise
}

/// Create a Promise that resolves after the specified number of seconds.
@available(*, deprecated, message: "Use Promise(value: ()).delay(seconds) instead")
public func delayPromise<Error>(_ seconds: TimeInterval, queue: DispatchQueue! = DispatchQueue.main) -> Promise<Void, Error> {
  return delayPromise(seconds, value: (), queue: queue)
}
