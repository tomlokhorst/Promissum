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

public func delayPromise<T>(seconds: NSTimeInterval, value: T, queue: dispatch_queue_t! = dispatch_get_main_queue()) -> Promise<T> {
  let source = PromiseSource<T>()

  delay(seconds, queue: queue) {
    source.resolve(value)
  }

  return source.promise
}

public func delayErrorPromise<T>(seconds: NSTimeInterval, error: NSError, queue: dispatch_queue_t! = dispatch_get_main_queue()) -> Promise<T> {
  let source = PromiseSource<T>()

  delay(seconds, queue: queue) {
    source.reject(error)
  }

  return source.promise
}

public func delayPromise(seconds: NSTimeInterval, queue: dispatch_queue_t! = dispatch_get_main_queue()) -> Promise<Void> {
  return delayPromise(seconds, (), queue: queue)
}

public func delay<T>(seconds: NSTimeInterval)(value: T) -> Promise<T> {
  return delayPromise(seconds).map { value }
}

public func delay<T>(seconds: NSTimeInterval)(error: NSError) -> Promise<T> {
  return delayPromise(seconds).flatMap { Promise(error: error) }
}
