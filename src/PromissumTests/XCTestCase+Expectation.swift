//
//  XCTestCase+Expectation.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-12-23.
//  Copyright © 2015 Tom Lokhorst. All rights reserved.
//

import XCTest
import Promissum

extension DispatchQueue {
  class var currentLabel: String {
    return String(cString: __dispatch_queue_get_label(nil))
  }
}

extension XCTestCase {

  func expectation<V, E>(_ p: Promise<V, E>, handler: () -> Void) {

    let ex = self.expectation(description: "Promise didn't finish")
    p.finally {
      handler()
      ex.fulfill()
    }

    waitForExpectations(timeout: 0.1, handler: nil)
  }

  @nonobjc
  func expectation(_ queue: DispatchQueue, handler: () -> Void) {

    let ex = self.expectation(description: "Dispatch queue")

    queue.async {
      handler()
      ex.fulfill()
    }

    waitForExpectations(timeout: 0.1, handler: nil)
  }

  @nonobjc
  func expectationQueue(_ queue: DispatchQueue, handler: (XCTestExpectation) -> Void) {

    let ex1 = self.expectation(description: "Dispatch queue")
    let ex2 = self.expectation(description: "Dispatch queue")

    queue.async {
      handler(ex1)
      ex2.fulfill()
    }

    waitForExpectations(timeout: 0.1, handler: nil)
  }

  @nonobjc
  func dispatch(_ queue: DispatchQueue, expectation: XCTestExpectation, handler: () -> Void) {

    queue.async {
      handler()
      expectation.fulfill()
    }
  }
}
