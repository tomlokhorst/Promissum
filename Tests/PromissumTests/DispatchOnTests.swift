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

private let test1QueueLabel = "com.nonstrict.promissum.test1"
private let test2QueueLabel = "com.nonstrict.promissum.test2"
private let test3QueueLabel = "com.nonstrict.promissum.test3"

private let test1Queue = DispatchQueue(label: test1QueueLabel, attributes: [])
private let test2Queue = DispatchQueue(label: test2QueueLabel, attributes: [])
private let test3Queue = DispatchQueue(label: test3QueueLabel, attributes: [])

private let test1QueueKey = DispatchSpecificKey<Void>()
private let test2QueueKey = DispatchSpecificKey<Void>()
private let test3QueueKey = DispatchSpecificKey<Void>()

class DispatchOnTests: XCTestCase {

  override func setUp() {
    test1Queue.setSpecific(key: test1QueueKey, value: ())
    test2Queue.setSpecific(key: test2QueueKey, value: ())
    test3Queue.setSpecific(key: test3QueueKey, value: ())
  }

  func testSyncOnQueue() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise.dispatchMain()

    p.then { _ in
      XCTAssert(Thread.isMainThread, "callback for queued dispatch method should be called on main queue")
      calls += 1
    }

    source.resolve(42)
    XCTAssertEqual(calls, 1, "Calls should be 1")

    p.then { _ in
      XCTAssert(Thread.isMainThread, "callback should be called on main queue")
      calls += 1
    }
    XCTAssertEqual(calls, 2, "Calls should be 2")
  }

  func testDispatchOnMainQueue() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise.dispatchMain()

    expectationQueue(test1Queue) { ex in

      XCTAssert(!Thread.isMainThread, "shouldn't be on main queue")

      p.then { _ in
        XCTAssert(Thread.isMainThread, "callback for queued dispatch method should be called on main queue")
        calls += 1
      }

      source.resolve(42)

      p.then { _ in
        XCTAssert(Thread.isMainThread, "callback should be called on main queue")
        calls += 1
      }

      self.dispatch(DispatchQueue.main, expectation: ex) {
        XCTAssertEqual(calls, 2, "Calls should be 2")
      }
    }
  }

  func testDispatchOnTestQueue() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise.dispatch(on: test2Queue)

    expectationQueue(test1Queue) { ex in

      XCTAssertNotNil(DispatchQueue.getSpecific(key: test1QueueKey), "callback for queued dispatch method should be called on specified queue")

      p.then { _ in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test2QueueKey), "callback for queued dispatch method should be called on specified queue")
        calls += 1
      }

      source.resolve(42)

      p.then { _ in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test2QueueKey), "callback for queued dispatch method should be called on specified queue")
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
    let p = source.promise.dispatch(on: test1Queue)

    p.then { _ in
      XCTAssertNotNil(DispatchQueue.getSpecific(key: test1QueueKey), "callback for queued dispatch method should be called on specified queue")
      calls += 1
    }

    p.dispatch(on: test2Queue).then { _ in
      XCTAssertNotNil(DispatchQueue.getSpecific(key: test2QueueKey), "callback for queued dispatch method should be called on specified queue")
      calls += 1
    }

    source.resolve(42)

    let ex = self.expectation(description: "Dispatch queue")

    delay(0.02) {
      XCTAssertEqual(calls, 2, "Calls should be 2")
      ex.fulfill()
    }

    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testMultipleMapDispatchOn() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let pr = source.promise.dispatch(on: test1Queue)

    let _ = pr
      .map { x -> Int in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test1QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(x, 40)

        calls += 1

        return x + 1
      }
      .dispatch(on: test2Queue)
      .map { x -> Int in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test2QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(x, 41)

        calls += 1

        return x + 1
      }
      .dispatch(on: test3Queue)
      .map { x -> Int in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test3QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(x, 42)

        calls += 1

        return x + 1
      }

    source.resolve(40)

    let ex = self.expectation(description: "Dispatch queue")

    delay(0.02) {
      XCTAssertEqual(calls, 3, "Calls should be 3")
      ex.fulfill()
    }

    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testMultipleFlatMapDispatchOn() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let pr = source.promise.dispatch(on: test1Queue)

    let _ = pr
      .flatMap { x -> Promise<Int, NSError> in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test1QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(x, 40)

        calls += 1

        return delayPromise(0.01, value: x + 1)
      }
      .dispatch(on: test2Queue)
      .flatMap { x -> Promise<Int, NSError> in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test2QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(x, 41)

        calls += 1

        return delayPromise(0.01, value: x + 1)
      }
      .dispatch(on: test3Queue)
      .flatMap { x -> Promise<Int, NSError> in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test3QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(x, 42)

        calls += 1

        return Promise(value: x + 1)
      }

    source.resolve(40)

    let ex = self.expectation(description: "Dispatch queue")

    delay(0.3) {
      XCTAssertEqual(calls, 3, "Calls should be 3")
      ex.fulfill()
    }

    waitForExpectations(timeout: 0.4, handler: nil)
  }

  func testMultipleFlatMapDelayDispatchOn() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let pr = source.promise.dispatch(on: test1Queue)

    let _ = pr
      .flatMap { x -> Promise<Int, NSError> in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test1QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(x, 40)

        calls += 1

        return delayPromise(0.01, value: x + 1, queue: test2Queue)
      }
      .dispatch(on: test2Queue)
      .flatMap { x -> Promise<Int, NSError> in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test2QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(x, 41)

        calls += 1

        return delayPromise(0.01, value: x + 1, queue: test1Queue)
      }
      .dispatch(on: test3Queue)
      .flatMap { x -> Promise<Int, NSError> in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test3QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(x, 42)

        calls += 1

        return Promise(value: x + 1)
      }

    source.resolve(40)

    let ex = self.expectation(description: "Dispatch queue")

    delay(0.3) {
      XCTAssertEqual(calls, 3, "Calls should be 3")
      ex.fulfill()
    }

    waitForExpectations(timeout: 0.4, handler: nil)
  }

  func testMultipleMapErrorDispatchOn() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let pr = source.promise.dispatch(on: test1Queue)

    let _ = pr
      .mapError { error -> NSError in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test1QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(error.code, 40)

        calls += 1

        return NSError(code: error.code + 1)
      }
      .dispatch(on: test2Queue)
      .mapError { error -> NSError in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test2QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(error.code, 41)

        calls += 1

        return NSError(code: error.code + 1)
      }
      .dispatch(on: test3Queue)
      .mapError { error -> NSError in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test3QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(error.code, 42)

        calls += 1

        return NSError(code: error.code + 1)
      }

    source.reject(NSError(code: 40))

    let ex = self.expectation(description: "Dispatch queue")

    delay(0.02) {
      XCTAssertEqual(calls, 3, "Calls should be 3")
      ex.fulfill()
    }

    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testMultipleFlatMapErrorDispatchOn() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let pr = source.promise.dispatch(on: test1Queue)

    let _ = pr
      .flatMapError { error -> Promise<Int, NSError> in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test1QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(error.code, 40)

        calls += 1

        return delayErrorPromise(0.01, error: NSError(code: error.code + 1))
      }
      .dispatch(on: test2Queue)
      .flatMapError { error -> Promise<Int, NSError> in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test2QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(error.code, 41)

        calls += 1

        return delayErrorPromise(0.01, error: NSError(code: error.code + 1))
      }
      .dispatch(on: test3Queue)
      .flatMapError { error -> Promise<Int, NSError> in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test3QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(error.code, 42)

        calls += 1

        return Promise(error: NSError(code: error.code + 1))
      }

    source.reject(NSError(code: 40))

    let ex = self.expectation(description: "Dispatch queue")

    delay(0.3) {
      XCTAssertEqual(calls, 3, "Calls should be 3")
      ex.fulfill()
    }

    waitForExpectations(timeout: 0.4, handler: nil)
  }

  func testMultipleMapResultDispatchOn() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let pr = source.promise.dispatch(on: test1Queue)

    let _ = pr
      .mapResult { result -> Result<Int, NSError> in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test1QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(result.value!, 40)

        calls += 1

        return Result.error(NSError(code: result.value! + 1))
      }
      .dispatch(on: test2Queue)
      .mapResult { result -> Result<Int, NSError> in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test2QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(result.error!.code, 41)

        calls += 1

        return Result.value(result.error!.code + 1)
      }
      .dispatch(on: test3Queue)
      .mapResult { result -> Result<Int, NSError> in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test3QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(result.value!, 42)

        calls += 1

        return Result.value(result.value! + 1)
      }

    source.resolve(40)

    let ex = self.expectation(description: "Dispatch queue")

    delay(0.02) {
      XCTAssertEqual(calls, 3, "Calls should be 3")
      ex.fulfill()
    }

    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testMultipleFlatMapResultDispatchOn() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let pr = source.promise.dispatch(on: test1Queue)

    let _ = pr
      .flatMapResult { result -> Promise<Int, NSError> in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test1QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(result.value!, 40)

        calls += 1

        return delayErrorPromise(0.01, error: NSError(code: result.value! + 1))
      }
      .dispatch(on: test2Queue)
      .flatMapResult { result -> Promise<Int, NSError> in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test2QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(result.error!.code, 41)

        calls += 1

        return delayPromise(0.01, value: result.error!.code + 1)
      }
      .dispatch(on: test3Queue)
      .flatMapResult { result -> Promise<Int, NSError> in
        XCTAssertNotNil(DispatchQueue.getSpecific(key: test3QueueKey), "callback for queued dispatch method should be called on specified queue")
        XCTAssertEqual(result.value!, 42)

        calls += 1

        return Promise(error: NSError(code: result.value! + 1))
      }

    source.resolve(40)

    let ex = self.expectation(description: "Dispatch queue")

    delay(0.3) {
      XCTAssertEqual(calls, 3, "Calls should be 3")
      ex.fulfill()
    }

    waitForExpectations(timeout: 0.4, handler: nil)
  }

}
