//
//  XCTestCase+Expectation.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-12-23.
//  Copyright © 2015 Tom Lokhorst. All rights reserved.
//

import XCTest
import Promissum

extension XCTestCase {

  func expectation<V, E>(p: Promise<V, E>, handler: () -> Void) {

    let ex = expectationWithDescription("Promise didn't finish")
    p.finally {
      handler()
      ex.fulfill()
    }

    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

}
