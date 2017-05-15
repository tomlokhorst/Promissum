//
//  SourceValueTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-12-31.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

class SourceValueTests: XCTestCase {

  func testValue() {
    var value: Int?

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    value = p.value

    source.resolve(42)

    XCTAssert(value == nil, "Value should be nil")
  }

  func testValueVoid() {
    var value: Int?

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    p.then { x in
      value = x
    }

    source.resolve(42)

    expectation(p) {
      XCTAssert(value == 42, "Value should be set")
    }
  }

  func testValueMap() {
    var value: Int?

    let source = PromiseSource<Int, NSError>()
    let p = source.promise
      .map { $0 + 1 }

    p.then { x in
      value = x
    }

    source.resolve(42)

    expectation(p) {
      XCTAssert(value == 43, "Value should be set")
    }
  }

  func testValueFlatMap() {
    var value: Int?

    let source = PromiseSource<Int, NSError>()
    let p = source.promise
      .flatMap { Promise(value: $0 + 1) }

    p.then { x in
      value = x
    }

    source.resolve(42)

    expectation(p) {
      XCTAssert(value == 43, "Value should be set")
    }
  }

  func testFinally() {
    var finally: Bool = false

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    p.finally {
      finally = true
    }

    source.resolve(42)

    expectation(p) {
      XCTAssert(finally, "Finally should be set")
    }
  }
}
