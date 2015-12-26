//
//  SideEffectOrderTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-01-11.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

class SideEffectOrderTests : XCTestCase {

  func testThen() {
    var step = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    p
      .then { _ in
        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
      }
      .then { _ in
        step += 1
        XCTAssertEqual(step, 2, "Should be step 2")
      }

    source.resolve(42)

    expectation(p) {
      XCTAssertEqual(step, 2, "Should be step 2")
    }
  }

  func testCatch() {
    var step = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    p
      .trap { _ in
        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
      }
      .trap { _ in
        step += 1
        XCTAssertEqual(step, 2, "Should be step 2")
      }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    expectation(p) {
      XCTAssertEqual(step, 2, "Should be step 2")
    }
  }

  func testMap() {
    var step = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    let q: Promise<Int, NSError> = p
      .then { value in
        XCTAssertEqual(value, 42, "Value should be 42")

        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
      }
      .map { value in
        XCTAssertEqual(value, 42, "Value should be 42")

        step += 1
        XCTAssertEqual(step, 2, "Should be step 2")
        return value + 1
      }
      .then { value in
        XCTAssertEqual(value, 43, "Value should be 43")

        step += 1
        XCTAssertEqual(step, 3, "Should be step 3")
      }

    source.resolve(42)

    expectation(q) {
      XCTAssertEqual(step, 3, "Should be step 3")
    }
  }

  func testMap2() {
    var step = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    let q: Promise<Int, NSError> = p
      .map { value in
        XCTAssertEqual(value, 42, "Value should be 42")

        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
        return value + 1
      }

    // As of version with GCD support:
    // callbacks registered to "map"-promise happen before callbacks registered after `map`
    p.then { value in
      XCTAssertEqual(value, 42, "Value should be 42")

      step += 1
      XCTAssertEqual(step, 3, "Should be step 3")
    }

    q.then { value in
      XCTAssertEqual(value, 43, "Value should be 43")

      step += 1
      XCTAssertEqual(step, 2, "Should be step 2")
    }

    source.resolve(42)

    expectation(q) {
      XCTAssertEqual(step, 3, "Should be step 3")
    }
  }

  func testMapError() {
    var step = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    let q: Promise<Int, NSError> = p
      .mapError { error in
        XCTAssertEqual(error.code, 42, "Error should be 42")

        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
        return NSError(domain: PromissumErrorDomain, code: error.code + 1, userInfo: nil)
      }

    // As of version with GCD support:
    // callbacks registered to "map"-promise happen before callbacks registered after `map`
    p.trap { error in
      XCTAssertEqual(error.code, 42, "Error should be 42")

      step += 1
      XCTAssertEqual(step, 3, "Should be step 3")
    }

    q.trap { error in
      XCTAssertEqual(error.code, 43, "Value should be 43")

      step += 1
      XCTAssertEqual(step, 2, "Should be step 2")
    }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    expectation(q) {
      XCTAssertEqual(step, 3, "Should be step 3")
    }
  }

  func testErrorMap() {
    var step = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    let q: Promise<Int, NSError> = p
      .map { value in
        step += 1
        XCTFail("Shouldn't happen")
        return value
      }

    // As of version with GCD support:
    // callbacks registered to "map"-promise happen before callbacks registered after `map`
    p.trap { error in
      XCTAssertEqual(error.code, 42, "Error should be 42")

      step += 1
      XCTAssertEqual(step, 2, "Should be step 2")
    }

    q.trap { error in
      XCTAssertEqual(error.code, 42, "Value should be 42")

      step += 1
      XCTAssertEqual(step, 1, "Should be step 1")
    }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    expectation(q) {
      XCTAssertEqual(step, 2, "Should be step 1")
    }
  }

  func testFlatMap() {
    var step = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    let q: Promise<Int, NSError> = p
      .then { value in
        XCTAssertEqual(value, 42, "Value should be 42")

        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
      }
      .flatMap { value in
        XCTAssertEqual(value, 42, "Value should be 42")

        step += 1
        XCTAssertEqual(step, 2, "Should be step 2")
        return Promise(value: value + 1)
      }
      .then { value in
        XCTAssertEqual(value, 43, "Value should be 43")

        step += 1
        XCTAssertEqual(step, 3, "Should be step 3")
      }

    source.resolve(42)

    expectation(q) {
      XCTAssertEqual(step, 3, "Should be step 3")
    }
  }

  func testFlatMapError() {
    var step = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    let q: Promise<Int, NSError> = p
      .trap { error in
        XCTAssertEqual(error.code, 42, "Value should be 42")

        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
      }
      .flatMapError { error in
        XCTAssertEqual(error.code, 42, "Value should be 42")

        step += 1
        XCTAssertEqual(step, 2, "Should be step 2")
        return Promise(error: NSError(domain: PromissumErrorDomain, code: error.code + 1, userInfo: nil))
      }
      .trap { error in
        XCTAssertEqual(error.code, 43, "Value should be 43")

        step += 1
        XCTAssertEqual(step, 3, "Should be step 3")
      }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    expectation(q) {
      XCTAssertEqual(step, 3, "Should be step 3")
    }
  }
}