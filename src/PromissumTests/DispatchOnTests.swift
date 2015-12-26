//
//  DispatchOnTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-12-24.
//  Copyright © 2015 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

let test1QueueLabel = "com.nonstrict.promissum.test1"
let test2QueueLabel = "com.nonstrict.promissum.test2"
let test3QueueLabel = "com.nonstrict.promissum.test3"

let test1Queue = dispatch_queue_create(test1QueueLabel, nil)
let test2Queue = dispatch_queue_create(test2QueueLabel, nil)
let test3Queue = dispatch_queue_create(test3QueueLabel, nil)


class DispatchOnTests: XCTestCase {

  func testSyncOnQueue() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise.dispatchMain()

    p.then { _ in
      XCTAssert(NSThread.isMainThread(), "callback for queued dispatch method should be called on main queue")
      calls += 1
    }

    source.resolve(42)
    XCTAssertEqual(calls, 1, "Calls should be 1")

    p.then { _ in
      XCTAssert(NSThread.isMainThread(), "callback should be called on main queue")
      calls += 1
    }
    XCTAssertEqual(calls, 2, "Calls should be 2")
  }

  func testDispatchOnMainQueue() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise.dispatchMain()

    expectationQueue(test1Queue) { ex in

      XCTAssert(!NSThread.isMainThread(), "shouldn't be on main queue")

      p.then { _ in
        XCTAssert(NSThread.isMainThread(), "callback for queued dispatch method should be called on main queue")
        calls += 1
      }

      source.resolve(42)

      p.then { _ in
        XCTAssert(NSThread.isMainThread(), "callback should be called on main queue")
        calls += 1
      }

      self.dispatch(dispatch_get_main_queue(), expectation: ex) {
        XCTAssertEqual(calls, 2, "Calls should be 2")
      }
    }
  }

  func testDispatchOnTestQueue() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise.dispatchOn(test2Queue)

    expectationQueue(test1Queue) { ex in

      XCTAssertEqual(dispatch_current_queue_name(), test1QueueLabel, "callback for queued dispatch method should be called on specified queue")

      p.then { _ in
        XCTAssertEqual(dispatch_current_queue_name(), test2QueueLabel, "callback for queued dispatch method should be called on specified queue")
        calls += 1
      }

      source.resolve(42)

      p.then { _ in
        XCTAssertEqual(dispatch_current_queue_name(), test2QueueLabel, "callback for queued dispatch method should be called on specified queue")
        calls += 1
      }

      delay(0.02) {
        XCTAssertEqual(calls, 2, "Calls should be 2")
        ex.fulfill()
      }
    }
  }

  func testMultipleDispatchOn() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise.dispatchOn(test1Queue)

    p.then { _ in
      XCTAssertEqual(dispatch_current_queue_name(), test1QueueLabel, "callback for queued dispatch method should be called on specified queue")
      calls += 1
    }

    p.dispatchOn(test2Queue).then { _ in
      XCTAssertEqual(dispatch_current_queue_name(), test2QueueLabel, "callback for queued dispatch method should be called on specified queue")
      calls += 1
    }

    source.resolve(42)

    let ex = expectationWithDescription("Dispatch queue")

    delay(0.02) {
      XCTAssertEqual(calls, 2, "Calls should be 2")
      ex.fulfill()
    }

    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

  func testMultipleMapDispatchOn() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let pr = source.promise.dispatchOn(test1Queue)

    pr
      .map { x -> Int in
        XCTAssertEqual(dispatch_current_queue_name(), test1QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(x, 40)

        calls += 1

        return x + 1
      }
      .dispatchOn(test2Queue)
      .map { x -> Int in
        XCTAssertEqual(dispatch_current_queue_name(), test2QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(x, 41)

        calls += 1

        return x + 1
      }
      .dispatchOn(test3Queue)
      .map { x -> Int in
        XCTAssertEqual(dispatch_current_queue_name(), test3QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(x, 42)

        calls += 1

        return x + 1
      }

    source.resolve(40)

    let ex = expectationWithDescription("Dispatch queue")

    delay(0.02) {
      XCTAssertEqual(calls, 3, "Calls should be 3")
      ex.fulfill()
    }

    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

  func testMultipleFlatMapDispatchOn() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let pr = source.promise.dispatchOn(test1Queue)

    pr
      .flatMap { x -> Promise<Int, NSError> in
        XCTAssertEqual(dispatch_current_queue_name(), test1QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(x, 40)

        calls += 1

        return delayPromise(0.01, value: x + 1)
      }
      .dispatchOn(test2Queue)
      .flatMap { x -> Promise<Int, NSError> in
        XCTAssertEqual(dispatch_current_queue_name(), test2QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(x, 41)

        calls += 1

        return delayPromise(0.01, value: x + 1)
      }
      .dispatchOn(test3Queue)
      .flatMap { x -> Promise<Int, NSError> in
        XCTAssertEqual(dispatch_current_queue_name(), test3QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(x, 42)

        calls += 1

        return Promise(value: x + 1)
      }

    source.resolve(40)

    let ex = expectationWithDescription("Dispatch queue")

    delay(0.3) {
      XCTAssertEqual(calls, 3, "Calls should be 3")
      ex.fulfill()
    }

    waitForExpectationsWithTimeout(0.4, handler: nil)
  }

  func testMultipleFlatMapDelayDispatchOn() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let pr = source.promise.dispatchOn(test1Queue)

    pr
      .flatMap { x -> Promise<Int, NSError> in
        XCTAssertEqual(dispatch_current_queue_name(), test1QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(x, 40)

        calls += 1

        return delayPromise(0.01, value: x + 1, queue: test2Queue)
      }
      .dispatchOn(test2Queue)
      .flatMap { x -> Promise<Int, NSError> in
        XCTAssertEqual(dispatch_current_queue_name(), test2QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(x, 41)

        calls += 1

        return delayPromise(0.01, value: x + 1, queue: test1Queue)
      }
      .dispatchOn(test3Queue)
      .flatMap { x -> Promise<Int, NSError> in
        XCTAssertEqual(dispatch_current_queue_name(), test3QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(x, 42)

        calls += 1

        return Promise(value: x + 1)
      }

    source.resolve(40)

    let ex = expectationWithDescription("Dispatch queue")

    delay(0.3) {
      XCTAssertEqual(calls, 3, "Calls should be 3")
      ex.fulfill()
    }

    waitForExpectationsWithTimeout(0.4, handler: nil)
  }

  func testMultipleMapErrorDispatchOn() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let pr = source.promise.dispatchOn(test1Queue)

    pr
      .mapError { error -> NSError in
        XCTAssertEqual(dispatch_current_queue_name(), test1QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(error.code, 40)

        calls += 1

        return NSError(code: error.code + 1)
      }
      .dispatchOn(test2Queue)
      .mapError { error -> NSError in
        XCTAssertEqual(dispatch_current_queue_name(), test2QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(error.code, 41)

        calls += 1

        return NSError(code: error.code + 1)
      }
      .dispatchOn(test3Queue)
      .mapError { error -> NSError in
        XCTAssertEqual(dispatch_current_queue_name(), test3QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(error.code, 42)

        calls += 1

        return NSError(code: error.code + 1)
      }

    source.reject(NSError(code: 40))

    let ex = expectationWithDescription("Dispatch queue")

    delay(0.02) {
      XCTAssertEqual(calls, 3, "Calls should be 3")
      ex.fulfill()
    }

    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

  func testMultipleFlatMapErrorDispatchOn() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let pr = source.promise.dispatchOn(test1Queue)

    pr
      .flatMapError { error -> Promise<Int, NSError> in
        XCTAssertEqual(dispatch_current_queue_name(), test1QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(error.code, 40)

        calls += 1

        return delayErrorPromise(0.01, error: NSError(code: error.code + 1))
      }
      .dispatchOn(test2Queue)
      .flatMapError { error -> Promise<Int, NSError> in
        XCTAssertEqual(dispatch_current_queue_name(), test2QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(error.code, 41)

        calls += 1

        return delayErrorPromise(0.01, error: NSError(code: error.code + 1))
      }
      .dispatchOn(test3Queue)
      .flatMapError { error -> Promise<Int, NSError> in
        XCTAssertEqual(dispatch_current_queue_name(), test3QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(error.code, 42)

        calls += 1

        return Promise(error: NSError(code: error.code + 1))
      }

    source.reject(NSError(code: 40))

    let ex = expectationWithDescription("Dispatch queue")

    delay(0.3) {
      XCTAssertEqual(calls, 3, "Calls should be 3")
      ex.fulfill()
    }

    waitForExpectationsWithTimeout(0.4, handler: nil)
  }

  func testMultipleMapResultDispatchOn() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let pr = source.promise.dispatchOn(test1Queue)

    pr
      .mapResult { result -> Result<Int, NSError> in
        XCTAssertEqual(dispatch_current_queue_name(), test1QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(result.value!, 40)

        calls += 1

        return Result.Error(NSError(code: result.value! + 1))
      }
      .dispatchOn(test2Queue)
      .mapResult { result -> Result<Int, NSError> in
        XCTAssertEqual(dispatch_current_queue_name(), test2QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(result.error!.code, 41)

        calls += 1

        return Result.Value(result.error!.code + 1)
      }
      .dispatchOn(test3Queue)
      .mapResult { result -> Result<Int, NSError> in
        XCTAssertEqual(dispatch_current_queue_name(), test3QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(result.value!, 42)

        calls += 1

        return Result.Value(result.value! + 1)
      }

    source.resolve(40)

    let ex = expectationWithDescription("Dispatch queue")

    delay(0.02) {
      XCTAssertEqual(calls, 3, "Calls should be 3")
      ex.fulfill()
    }

    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

  func testMultipleFlatMapResultDispatchOn() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let pr = source.promise.dispatchOn(test1Queue)

    pr
      .flatMapResult { result -> Promise<Int, NSError> in
        XCTAssertEqual(dispatch_current_queue_name(), test1QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(result.value!, 40)

        calls += 1

        return delayErrorPromise(0.01, error: NSError(code: result.value! + 1))
      }
      .dispatchOn(test2Queue)
      .flatMapResult { result -> Promise<Int, NSError> in
        XCTAssertEqual(dispatch_current_queue_name(), test2QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(result.error!.code, 41)

        calls += 1

        return delayPromise(0.01, value: result.error!.code + 1)
      }
      .dispatchOn(test3Queue)
      .flatMapResult { result -> Promise<Int, NSError> in
        XCTAssertEqual(dispatch_current_queue_name(), test3QueueLabel, "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(result.value!, 42)

        calls += 1

        return Promise(error: NSError(code: result.value! + 1))
      }

    source.resolve(40)

    let ex = expectationWithDescription("Dispatch queue")

    delay(0.3) {
      XCTAssertEqual(calls, 3, "Calls should be 3")
      ex.fulfill()
    }

    waitForExpectationsWithTimeout(0.4, handler: nil)
  }

}
