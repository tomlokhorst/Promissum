//
//  MultipleErrorTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-12-31.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

class MultipleErrorTests: XCTestCase {

  func testValueVoid() {
    var calls = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    p.catch { _ in
      calls += 1
    }
    p.catch { _ in
      calls += 1
    }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    XCTAssertEqual(calls, 2, "Calls should be 2")
  }

  func testValueMap() {
    var calls = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    p.catch { _ in
      calls += 1
    }
    p.mapError { $0.code + 1 }
      .then { _ in
        calls += 1
      }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    XCTAssertEqual(calls, 2, "Calls should be 2")
  }

  func testValueFlatMap() {
    var calls = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    p.catch { _ in
      calls += 1
    }
    p.flatMapError { Promise(value: $0.code + 1) }
      .then { _ in
        calls += 1
      }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    XCTAssert(calls == 2, "Calls should be 2")
  }

  func testValueFlatMap2() {
    var calls = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    p.catch { _ in
      calls += 1
    }
    p.flatMapError { Promise(error: NSError(domain: PromissumErrorDomain, code: $0.code + 1, userInfo: nil))  }
      .catch { _ in
        calls += 1
      }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    XCTAssert(calls == 2, "Calls should be 2")
  }

  func testFinally() {
    var calls = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    p.finally {
      calls += 1
    }
    p.map { $0 + 1 }
      .finally {
        calls += 1
      }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    XCTAssert(calls == 2, "Calls should be 2")
  }
}
