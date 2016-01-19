//
//  XCTestCase+Expectation.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-12-23.
//  Copyright © 2015 Tom Lokhorst. All rights reserved.
//

import XCTest
import Promissum

func dispatch_current_queue_name() -> String {
  return String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
}

extension XCTestCase {

  func expectation<V, E>(p: Promise<V, E>, handler: () -> Void) {

    let ex = expectationWithDescription("Promise didn't finish")
    p.finally {
      handler()
      ex.fulfill()
    }

    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

  @nonobjc
  func expectation(queue: dispatch_queue_t, handler: () -> Void) {

    let ex = expectationWithDescription("Dispatch queue")

    dispatch_async(queue) {
      handler()
      ex.fulfill()
    }

    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

  @nonobjc
  func expectationQueue(queue: dispatch_queue_t, handler: XCTestExpectation -> Void) {

    let ex1 = expectationWithDescription("Dispatch queue")
    let ex2 = expectationWithDescription("Dispatch queue")

    dispatch_async(queue) {
      handler(ex1)
      ex2.fulfill()
    }

    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

  @nonobjc
  func dispatch(queue: dispatch_queue_t, expectation: XCTestExpectation, handler: () -> Void) {

    dispatch_async(queue) {
      handler()
      expectation.fulfill()
    }
  }
}
