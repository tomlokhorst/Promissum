//
//  Delay.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-01-12.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation

public func delay(seconds: NSTimeInterval, queue: dispatch_queue_t! = dispatch_get_main_queue(), block: dispatch_block_t!) {
  let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))

  dispatch_after(when, queue, block)
}

public func delayPromise<Value, Error>(seconds: NSTimeInterval, value: Value, queue: dispatch_queue_t! = dispatch_get_main_queue()) -> Promise<Value, Error> {
  let source = PromiseSource<Value, Error>()

  delay(seconds, queue: queue) {
    source.resolve(value)
  }

  return source.promise
}

public func delayErrorPromise<Value, Error>(seconds: NSTimeInterval, error: Error, queue: dispatch_queue_t! = dispatch_get_main_queue()) -> Promise<Value, Error> {
  let source = PromiseSource<Value, Error>()

  delay(seconds, queue: queue) {
    source.reject(error)
  }

  return source.promise
}

public func delayPromise<Error>(seconds: NSTimeInterval, queue: dispatch_queue_t! = dispatch_get_main_queue()) -> Promise<Void, Error> {
  return delayPromise(seconds, (), queue: queue)
}

public func delay<Value, Error>(seconds: NSTimeInterval)(_ value: Value) -> Promise<Value, Error> {
  return delayPromise(seconds).map { value }
}

public func delay<Value, Error>(seconds: NSTimeInterval)(_ error: Error) -> Promise<Value, Error> {
  return delayPromise(seconds).flatMap { Promise(error: error) }
}
