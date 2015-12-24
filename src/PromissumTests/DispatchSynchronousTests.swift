//
//  DispatchSynchronousTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-07-01.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

class DispatchSynchronousTests: XCTestCase {

  func testSynchronousIsSync() {
    var calls = 0

    let source = PromiseSource<Int, NSError>(dispatch: .Synchronous)
    let p = source.promise
    p.then { _ in
      calls += 1
    }

    source.resolve(42)

    XCTAssertEqual(calls, 1, "handler should have been called synchronously on current thread")
  }

  func testSynchronousAfterIsSync() {
    var calls = 0

    let source = PromiseSource<Int, NSError>(dispatch: .Synchronous)

    source.resolve(42)

    source.promise
      .then { _ in
        calls += 1
      }

    XCTAssertEqual(calls, 1, "handler should have been called synchronously on current thread")
  }

  func testSynchronousValue() {
    var calls = 0

    let p = Promise<Int, NSError>(value: 42)
    p.then { _ in
      calls += 1
    }

    XCTAssertEqual(calls, 1, "handler should have been called synchronously on current thread")
  }

  func testSynchronousError() {
    var calls = 0

    let p = Promise<Int, NSError>(error: NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))
    p.trap { _ in
      calls += 1
    }

    XCTAssertEqual(calls, 1, "handler should have been called synchronously on current thread")
  }

  func testSynchronousFinally() {
    var calls = 0

    let source = PromiseSource<Int, NSError>(dispatch: .Synchronous)
    let p = source.promise

    p.finally {
      calls += 1
    }

    source.resolve(42)

    XCTAssertEqual(calls, 1, "handler should have been called synchronously on current thread")
  }

  func testSynchronousMap() {
    var calls = 0

    let source = PromiseSource<Int, NSError>(dispatch: .Synchronous)
    let p = source.promise

    p.map { x -> Int in
      calls += 1

      return x
    }

    source.resolve(42)

    XCTAssertEqual(calls, 1, "handler should have been called synchronously on current thread")
  }

  func testSynchronousFlatMap() {
    var calls = 0

    let source = PromiseSource<Int, NSError>(dispatch: .Synchronous)
    let p = source.promise

    p.flatMap { x -> Promise<Int, NSError> in
      calls += 1

      return Promise(value: x)
    }

    source.resolve(42)

    XCTAssertEqual(calls, 1, "handler should have been called synchronously on current thread")
  }

  func testSynchronousMapThen() {
    var calls = 0

    let source = PromiseSource<Int, NSError>(dispatch: .Synchronous)
    let p = source.promise

    p.map { x -> Int in
      calls += 1

      return x
    }
    .then { _ in
      calls += 2
    }

    source.resolve(42)

    XCTAssertEqual(calls, 3, "handler should have been called synchronously on current thread")
  }

  func testSynchronousFlatMapThen() {
    var calls = 0

    let source = PromiseSource<Int, NSError>(dispatch: .Synchronous)
    let p = source.promise

    p.flatMap { x -> Promise<Int, NSError> in
      calls += 1

      return Promise(value: x)
    }
    .then { _ in
      calls += 2
    }

    source.resolve(42)

    XCTAssertEqual(calls, 3, "handler should have been called synchronously on current thread")
  }

  func testSynchronousMapFinally() {
    var calls = 0

    let source = PromiseSource<Int, NSError>(dispatch: .Synchronous)
    let p = source.promise

    p.map { x -> Int in
      calls += 1

      return x
    }
    .finally {
      calls += 2
    }

    source.resolve(42)

    XCTAssertEqual(calls, 3, "handler should have been called synchronously on current thread")
  }

  func testSynchronousFlatMapFinally() {
    var calls = 0

    let source = PromiseSource<Int, NSError>(dispatch: .Synchronous)
    let p = source.promise

    p.flatMap { x -> Promise<Int, NSError> in
      calls += 1

      return Promise(value: x)
    }
    .finally {
      calls += 2
    }

    source.resolve(42)

    XCTAssertEqual(calls, 3, "handler should have been called synchronously on current thread")
  }
}
