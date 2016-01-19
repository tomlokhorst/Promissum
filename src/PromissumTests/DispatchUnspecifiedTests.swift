//
//  DispatchUnspecifiedTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-01-11.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

class DispatchUnspecifiedTests: XCTestCase {

  func testUnspecifiedAlreadyOnMain() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise
    p.then { _ in
      calls += 1
    }

    source.resolve(42)

    XCTAssert(NSThread.isMainThread(), "Should be running on main thread")
    XCTAssertEqual(calls, 1, "Tests are run on main thread, handler should have been resolved synchronously.")
  }

  func testUnspecifiedNotOnMainSync() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise
    p.then { _ in
      calls += 1
    }

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
      XCTAssert(!NSThread.isMainThread(), "Shouldn't be running on main thread")

      source.resolve(42)

      XCTAssertEqual(calls, 0, "handler shouldn't have been called yet on current thread")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testUnspecifiedResolved() {

    let p = Promise<Int, NSError>(value: 42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")


    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
      XCTAssert(!NSThread.isMainThread(), "Shouldn't be running on main thread")

      p.then { _ in
        XCTAssert(NSThread.isMainThread(), "callback for unspecified dispatch method should be called on main queue")
        expectation.fulfill()
      }
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testUnspecifiedThen() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    p.then { _ in
      XCTAssert(NSThread.isMainThread(), "callback for unspecified dispatch method should be called on main queue")
      calls += 1
    }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(NSThread.isMainThread(), "callback for unspecified dispatch method should be called on main queue")
      XCTAssertEqual(calls, 1, "Calls should be 1")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testUnspecifiedFinally() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    p.finally {
      XCTAssert(NSThread.isMainThread(), "callback for unspecified dispatch method should be called on main queue")
      calls += 1
    }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(NSThread.isMainThread(), "callback for unspecified dispatch method should be called on main queue")
      XCTAssertEqual(calls, 1, "Calls should be 1")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testUnspecifiedMap() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    let q: Promise<Int, NSError> = p
      .map { x in
        XCTAssert(NSThread.isMainThread(), "callback for unspecified dispatch method should be called on main queue")
        calls += 1

        return x
      }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    q.finally {
      XCTAssertEqual(calls, 1, "Calls should be 1")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testUnspecifiedFlatMap() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    let q: Promise<Int, NSError> = p
      .flatMap { x in
        XCTAssert(NSThread.isMainThread(), "callback for unspecified dispatch method should be called on main queue")
        calls += 1

        return Promise(value: x)
      }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    q.finally {
      XCTAssertEqual(calls, 1, "Calls should be 1")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testUnspecifiedMapThen() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    let q: Promise<Int, NSError> = p
      .map { x in
        XCTAssert(NSThread.isMainThread(), "callback for unspecified dispatch method should be called on main queue")
        calls += 1

        return x
      }
      .then { _ in
        XCTAssert(NSThread.isMainThread(), "callback for unspecified dispatch method should be called on main queue")
        calls += 1
      }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    q.finally {
      XCTAssertEqual(calls, 2, "Calls should be 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testUnspecifiedFlatMapThen() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    let q: Promise<Int, NSError> = p
      .flatMap { x in
        XCTAssert(NSThread.isMainThread(), "callback for unspecified dispatch method should be called on main queue")
        calls += 1

        return Promise(value: x)
      }
      .then { _ in
        XCTAssert(NSThread.isMainThread(), "callback for unspecified dispatch method should be called on main queue")
        calls += 1
      }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    q.finally {
      XCTAssertEqual(calls, 2, "Calls should be 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testUnspecifiedMapFinally() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    let q: Promise<Int, NSError> = p
      .map { x in
        XCTAssert(NSThread.isMainThread(), "callback for unspecified dispatch method should be called on main queue")
        calls += 1

        return x
      }
      .finally {
        XCTAssert(NSThread.isMainThread(), "callback for unspecified dispatch method should be called on main queue")
        calls += 1
      }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    q.finally {
      XCTAssertEqual(calls, 2, "Calls should be 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testUnspecifiedFlatMapFinally() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    let q: Promise<Int, NSError> = p
      .flatMap { x in
        XCTAssert(NSThread.isMainThread(), "callback for unspecified dispatch method should be called on main queue")
        calls += 1

        return Promise(value: x)
      }
      .finally {
        XCTAssert(NSThread.isMainThread(), "callback for unspecified dispatch method should be called on main queue")
        calls += 1
      }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    q.finally {
      XCTAssertEqual(calls, 2, "Calls should be 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }
}
