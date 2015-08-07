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

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    p.trap { _ in
      calls += 1
    }
    p.trap { _ in
      calls += 1
    }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    XCTAssertEqual(calls, 2, "Calls should be 2")
  }

  func testValueMap() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    p.trap { _ in
      calls += 1
    }
    p.mapError { $0.code + 1 }
      .trap { _ in
        calls += 1
      }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    XCTAssertEqual(calls, 2, "Calls should be 2")
  }

  func testValueFlatMap() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    p.trap { _ in
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

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    p.trap { _ in
      calls += 1
    }
    p.flatMapError { Promise(error: NSError(domain: PromissumErrorDomain, code: $0.code + 1, userInfo: nil))  }
      .trap { _ in
        calls += 1
      }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    XCTAssert(calls == 2, "Calls should be 2")
  }

  func testValueFlatMap3() {
    var calls = 0

    let source1 = PromiseSource<Int, NSError>()
    let p1 = source1.promise
    let source2 = PromiseSource<Int, NSError>()
    let p2 = source2.promise

    p1.trap { _ in
      calls += 1
    }
    p1.flatMapError { _ in p2 }
      .then { _ in
        calls += 1
      }

    source1.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))
    source2.resolve(42)

    XCTAssert(calls == 2, "Calls should be 2")
  }

  func testValueFlatMap4() {
    var calls = 0

    let source1 = PromiseSource<Int, NSError>()
    let p1 = source1.promise
    let source2 = PromiseSource<Int, NSError>()
    let p2 = source2.promise

    p1.trap { _ in
      calls += 1
    }
    p1.flatMapError { _ in p2 }
      .trap { _ in
        calls += 1
      }

    source1.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))
    source2.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    XCTAssert(calls == 2, "Calls should be 2")
  }

  func testFinally() {
    var calls = 0

    let source = PromiseSource<Int, NSError>()
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
