//
//  InitialValueTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-12-31.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

class InitialValueTests: XCTestCase {

  func testValue() {
    var value: Int?

    let p: Promise<Int, NSError> = Promise(value: 42)

    value = p.value

    XCTAssert(value == 42, "Value should be set")
  }

  func testValueVoid() {
    var value: Int?

    let p: Promise<Int, NSError> = Promise(value: 42)

    p.then { x in
      value = x
    }

    expectation(p) {
      XCTAssert(value == 42, "Value should be set")
    }
  }

  func testValueMap() {
    var value: Int?

    let p: Promise<Int, NSError> = Promise(value: 42)
      .map { $0 + 1 }

    p.then { x in
      value = x
    }

    expectation(p) {
      XCTAssert(value == 43, "Value should be set")
    }
  }

  func testValueFlatMap() {
    var value: Int?

    let p: Promise<Int, NSError> = Promise(value: 42)
      .flatMap { Promise(value: $0 + 1) }

    p.then { x in
      value = x
    }

    expectation(p) {
      XCTAssert(value == 43, "Value should be set")
    }
  }

  func testFinally() {
    var finally: Bool = false

    let p = Promise<Int, NSError>(value: 42)

    p.finally {
      finally = true
    }

    expectation(p) {
      XCTAssert(finally, "Finally should be set")
    }
  }
}
