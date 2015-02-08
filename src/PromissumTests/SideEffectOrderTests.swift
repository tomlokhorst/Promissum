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

    let source = PromiseSource<Int>()
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
  }

  func testCatch() {
    var step = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    p
      .catch { _ in
        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
      }
      .catch { _ in
        step += 1
        XCTAssertEqual(step, 2, "Should be step 2")
      }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))
  }

  func testMap() {
    var step = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    let q: Promise<Int> = p
      .then { _ in
        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
      }
      .map { x in
        step += 1
        XCTAssertEqual(step, 2, "Should be step 2")
        return x
      }
      .then { _ in
        step += 1
        XCTAssertEqual(step, 3, "Should be step 3")
      }

    source.resolve(42)
  }

  func testMapError() {
    var step = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    let q: Promise<Int> = p
      .catch { _ in
        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
      }
      .mapError { error in
        step += 1
        XCTAssertEqual(step, 2, "Should be step 2")
        return error.code
      }
      .catch { _ in
        step += 1
        XCTAssertEqual(step, 3, "Should be step 3")
      }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))
  }

  func testMap2() {
    var step = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    let q: Promise<Int> = p
      .map { x in
        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
        return x
      }

    p.then { _ in
      step += 1
      XCTAssertEqual(step, 2, "Should be step 2")
    }

    q.then { _ in
      step += 1
      XCTAssertEqual(step, 3, "Should be step 3")
    }

    source.resolve(42)
  }

  func testMapError2() {
    var step = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    let q: Promise<Int> = p
      .mapError { error in
        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
        return error.code
      }

    p.catch { _ in
      step += 1
      XCTAssertEqual(step, 2, "Should be step 2")
    }

    q.catch { _ in
      step += 1
      XCTAssertEqual(step, 3, "Should be step 3")
    }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))
  }

  func testFlatMap() {
    var step = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    let q: Promise<Int> = p
      .then { _ in
        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
      }
      .flatMap { x in
        step += 1
        XCTAssertEqual(step, 2, "Should be step 2")
        return Promise(value: x)
      }
      .then { _ in
        step += 1
        XCTAssertEqual(step, 3, "Should be step 3")
      }

    source.resolve(42)
  }

  func testFlatMapError() {
    var step = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    let q: Promise<Int> = p
      .catch { _ in
        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
      }
      .flatMapError { error in
        step += 1
        XCTAssertEqual(step, 2, "Should be step 2")
        return Promise(error: error)
      }
      .catch { _ in
        step += 1
        XCTAssertEqual(step, 3, "Should be step 3")
      }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))
  }

  func testFlatMap2() {
    var step = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    let q: Promise<Int> = p
      .flatMap { x in
        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
        return Promise(value: x)
      }

    p.then { _ in
      step += 1
      XCTAssertEqual(step, 2, "Should be step 2")
    }

    q.then { _ in
      step += 1
      XCTAssertEqual(step, 3, "Should be step 3")
    }

    source.resolve(42)
  }

  func testFlatMapError2() {
    var step = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    let q: Promise<Int> = p
      .flatMapError { error in
        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
        return Promise(error: error)
      }

    p.catch { _ in
      step += 1
      XCTAssertEqual(step, 2, "Should be step 2")
    }

    q.catch { _ in
      step += 1
      XCTAssertEqual(step, 3, "Should be step 3")
    }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))
  }
}