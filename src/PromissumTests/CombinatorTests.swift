//
//  CombinatorTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-01-07.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

class CombinatorTests: XCTestCase {

  func testFlattenValueValue() {
    var value: Int?

    let source1 = PromiseSource<Promise<Int, NSError>, NSError>()
    let source2 = PromiseSource<Int, NSError>()
    let outer = source1.promise
    let inner = source2.promise

    flatten(outer)
      .then { x in
        value = x
      }

    source1.resolve(inner)
    source2.resolve(42)

    XCTAssert(value == 42, "Value should be 42")
  }

  func testFlattenValueError() {
    var error: NSError?

    let source1 = PromiseSource<Promise<Int, NSError>, NSError>()
    let source2 = PromiseSource<Int, NSError>()
    let outer = source1.promise
    let inner = source2.promise

    flatten(outer)
      .trap { e in
        error = e
      }

    source1.resolve(inner)
    source2.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    XCTAssert(error?.code == 42, "Error should be 42")
  }

  func testFlattenErrorError() {
    var error: NSError?

    let source1 = PromiseSource<Promise<Int, NSError>, NSError>()
    let source2 = PromiseSource<Int, NSError>()
    let outer = source1.promise
    let inner = source2.promise

    flatten(outer)
      .trap { e in
        error = e
      }

    source1.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    XCTAssert(error?.code == 42, "Error should be 42")
  }

  func testBothValue() {
    var value: Int?

    let source1 = PromiseSource<Int, NSError>()
    let source2 = PromiseSource<Int, NSError>()
    let p1 = source1.promise
    let p2 = source2.promise

    whenBoth(p1, p2)
      .then { (x, y) in
        value = x + y
      }

    source1.resolve(40)
    source2.resolve(2)

    XCTAssert(value == 42, "Value should be 42")
  }

  func testBothError() {
    var error: Int?

    let source1 = PromiseSource<Int, NSError>()
    let source2 = PromiseSource<Int, NSError>()
    let p1 = source1.promise
    let p2 = source2.promise

    whenBoth(p1, p2)
      .trap { e in
        error = e.code
      }

    source1.resolve(40)
    source2.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    XCTAssert(error == 42, "Error should be 42")
  }

  func testEitherLeft() {
    var value: Int?

    let source1 = PromiseSource<Int, NSError>()
    let source2 = PromiseSource<Int, NSError>()
    let p1 = source1.promise
    let p2 = source2.promise

    whenEither(p1, p2)
      .then { x in
        value = x
      }
      .trap { e in
        value = e.code
      }

    source1.resolve(1)
    source2.reject(NSError(domain: PromissumErrorDomain, code: 2, userInfo: nil))

    XCTAssert(value == 1, "Value should be 1")
  }

  func testEitherRight() {
    var value: Int?

    let source1 = PromiseSource<Int, NSError>()
    let source2 = PromiseSource<Int, NSError>()
    let p1 = source1.promise
    let p2 = source2.promise

    whenEither(p1, p2)
      .then { x in
        value = x
      }
      .trap { e in
        value = e.code
      }

    source1.reject(NSError(domain: PromissumErrorDomain, code: 1, userInfo: nil))
    source2.resolve(2)

    XCTAssert(value == 2, "Value should be 2")
  }

  func testEitherError() {
    var value: Int?

    let source1 = PromiseSource<Int, NSError>()
    let source2 = PromiseSource<Int, NSError>()
    let p1 = source1.promise
    let p2 = source2.promise

    whenEither(p1, p2)
      .then { x in
        value = x
      }
      .trap { e in
        value = e.code
      }

    source1.reject(NSError(domain: PromissumErrorDomain, code: 1, userInfo: nil))
    source2.reject(NSError(domain: PromissumErrorDomain, code: 2, userInfo: nil))

    XCTAssert(value == 2, "Value should be 2")
  }

  func testWhenAllResolved() {
    var values: [Int]?

    let source1 = PromiseSource<Int, NSError>()
    let source2 = PromiseSource<Int, NSError>()
    let p1 = source1.promise
    let p2 = source2.promise

    whenAll([p1, p2])
      .then { xs in
        values = xs
      }

    source2.resolve(2)
    source1.resolve(1)

    XCTAssert(values != nil && values! == [1, 2], "Values should be [1, 2]")
  }

  func testWhenAnyResolved() {
    var value: Int?

    let source1 = PromiseSource<Int, NSError>()
    let source2 = PromiseSource<Int, NSError>()
    let p1 = source1.promise
    let p2 = source2.promise

    whenAny([p1, p2])
      .then { x in
        value = x
      }

    source2.resolve(2)

    XCTAssert(value == 2, "Value should be 2")
  }

  func testWhenAllEmpy() {
    var values: [Int]?

    let promises: [Promise<Int, NSError>] = []

    whenAll(promises)
      .then { xs in
        values = xs
      }

    XCTAssert(values != nil && values! == [], "Values should be [1]")
  }

  func testWhenAnyEmpty() {
    var value: Int?
    var error: NSError?

    let promises: [Promise<Int, NSError>] = []

    whenAny(promises)
      .then { x in
        value = x
      }
      .trap { e in
        error = e
      }

    XCTAssert(value == nil, "Value shouldn't be set")
    XCTAssert(error == nil, "Error shouldn't be set")
  }

  func testWhenAllFinalized() {
    var finalized = false

    let source1 = PromiseSource<Int, NSError>()
    let source2 = PromiseSource<Int, NSError>()
    let p1 = source1.promise
    let p2 = source2.promise

    whenAllFinalized([p1, p2])
      .then {
        finalized = true
      }

    source1.resolve(1)
    source2.reject(NSError(domain: PromissumErrorDomain, code: 2, userInfo: nil))

    XCTAssert(finalized, "Finalized should be set")
  }

  func testWhenAnyFinalized() {
    var finalized = false

    let source1 = PromiseSource<Int, NSError>()
    let source2 = PromiseSource<Int, NSError>()
    let p1 = source1.promise
    let p2 = source2.promise

    whenAnyFinalized([p1, p2])
      .then {
        finalized = true
      }

    source1.resolve(1)

    XCTAssert(finalized, "Finalized should be set")
  }
}
