//
//  DeinitWarningTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 03/12/15.
//  Copyright © 2015 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

class DeinitWarningTests: XCTestCase {

  func testUnresolvedSourceDeinit() {
    var value: Int?

    makeUnresolvedPromise()
      .then { x in
        value = x
      }

    XCTAssert(value == 42, "Value should be 42")
  }

  func makeUnresolvedPromise() -> Promise<Int, NSError> {
    let source = PromiseSource<Int, NSError>()
    source.warnUnresolvedDeinit = Warning.Print

    return source.promise
  }

  func testUnresolvedMapDeinit() {
    var value: Int?

    mappedPromise()
      .then { x in
        value = x
      }

    XCTAssert(value == 42, "Value should be 42")
  }

  func mappedPromise() -> Promise<Int, NSError> {
    return makeUnresolvedPromise().map { x in x * 2 }
  }

  func testUnresolvedTwoDeinit() {
    var value: Int?

    let promise = makeUnresolvedPromise()

    promise
      .map { $0 }
      .then { x in
        value = x
      }

    XCTAssert(value == 42, "Value should be 42")
  }
}
