//
//  DispatchQueueTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-07-17.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

let testQueueLabel = "com.nonstrict.promissum.tests"
let testQueue = dispatch_queue_create(testQueueLabel, nil)

class DispatchQueueTests: XCTestCase {

  func testQueueThen() {
    var calls = 0

    let source = PromiseSource<Int, NSError>(dispatch: .OnQueue(testQueue))
    let p = source.promise

    p.then { _ in
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")
      calls += 1
    }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")

      XCTAssertEqual(calls, 1, "Calls should be 1")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testResolvedQueue() {

    let source = PromiseSource<Int, NSError>(dispatch: .OnQueue(testQueue))
    let q = source.promise.map { x in
      return x + 1
    }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    delay(0.02) {
      XCTAssert(NSThread.isMainThread(), "callback for unspecified dispatch method should be called on main queue")
      q.then { _ in
        let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
        XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")

        expectation.fulfill()
      }
    }

    waitForExpectationsWithTimeout(1, handler: nil)
  }

  func testQueueFinally() {
    var calls = 0

    let source = PromiseSource<Int, NSError>(dispatch: .OnQueue(testQueue))
    let p = source.promise

    p.finally {
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")
      calls += 1
    }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")

      XCTAssertEqual(calls, 1, "Calls should be 1")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testQueueMap() {
    var calls = 0

    let source = PromiseSource<Int, NSError>(dispatch: .OnQueue(testQueue))
    let p = source.promise

    let q: Promise<Int, NSError> = p
      .map { x in
        let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
        XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")
        calls += 1

        return x
    }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    q.finally {
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")

      XCTAssertEqual(calls, 1, "Calls should be 1")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testQueueFlatMap() {
    var calls = 0

    let source = PromiseSource<Int, NSError>(dispatch: .OnQueue(testQueue))
    let p = source.promise

    let q: Promise<Int, NSError> = p
      .flatMap { x in
        let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
        XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")
        calls += 1

        return Promise(value: x)
    }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    q.finally {
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")

      XCTAssertEqual(calls, 1, "Calls should be 1")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testQueueMapThen() {
    var calls = 0

    let source = PromiseSource<Int, NSError>(dispatch: .OnQueue(testQueue))
    let p = source.promise

    let q: Promise<Int, NSError> = p
      .map { x in
        let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
        XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")
        calls += 1

        return x
      }
      .then { _ in
        let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
        XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")
        calls += 2
    }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    q.finally {
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")

      XCTAssertEqual(calls, 3, "Calls should be 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testQueueFlatMapThen() {
    var calls = 0

    let source = PromiseSource<Int, NSError>(dispatch: .OnQueue(testQueue))
    let p = source.promise

    let q: Promise<Int, NSError> = p
      .flatMap { x in
        let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
        XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")
        calls += 1

        return Promise(value: x)
      }
      .then { _ in
        let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
        XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")
        calls += 2
    }


    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    q.finally {
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")

      XCTAssertEqual(calls, 3, "Calls should be 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testQueueMapFinally() {
    var calls = 0

    let source = PromiseSource<Int, NSError>(dispatch: .OnQueue(testQueue))
    let p = source.promise

    let q: Promise<Int, NSError> = p
      .map { x in
        let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
        XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")
        calls += 1

        return x
      }
      .finally {
        let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
        XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")
        calls += 2
      }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    q.finally {
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")

      XCTAssertEqual(calls, 3, "Calls should be 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testQueueFlatMapFinally() {
    var calls = 0

    let source = PromiseSource<Int, NSError>(dispatch: .OnQueue(testQueue))
    let p = source.promise

    let q: Promise<Int, NSError> = p
      .flatMap { x in
        let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
        XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")
        calls += 1

        return Promise(value: x)
      }
      .finally {
        let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
        XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")
        calls += 2
    }


    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    q.finally {
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, testQueueLabel, "callback for queued dispatch method should be called on specified queue")

      XCTAssertEqual(calls, 3, "Calls should be 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }
}
