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

let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)

class DispatchSynchronousTests: XCTestCase {

  func testSynchronousIsSync() {
    expectation(backgroundQueue) {
      var calls = 0

      let source = PromiseSource<Int, NSError>(dispatch: .Synchronous)
      let p = source.promise
      p.then { _ in
        calls += 1
      }

      source.resolve(42)

      XCTAssertEqual(calls, 1, "handler should have been called synchronously on current thread")
    }
  }

  func testSynchronousAfterIsSync() {
    expectation(backgroundQueue) {
      var calls = 0

      let source = PromiseSource<Int, NSError>(dispatch: .Synchronous)

      source.resolve(42)

      source.promise
        .then { _ in
          calls += 1
        }

      XCTAssertEqual(calls, 1, "handler should have been called synchronously on current thread")
    }
  }

  func testSynchronousFinally() {
    expectation(backgroundQueue) {
      var calls = 0

      let source = PromiseSource<Int, NSError>(dispatch: .Synchronous)
      let p = source.promise

      p.finally {
        calls += 1
      }

      source.resolve(42)

      XCTAssertEqual(calls, 1, "handler should have been called synchronously on current thread")
    }
  }

  func testSynchronousMap() {
    expectation(backgroundQueue) {
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
  }

  func testSynchronousFlatMap() {
    expectation(backgroundQueue) {
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
  }

  func testSynchronousMapThen() {
    expectation(backgroundQueue) {
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
  }

  func testSynchronousFlatMapThen() {
    expectation(backgroundQueue) {
      var calls = 0

      let source = PromiseSource<Int, NSError>(dispatch: .Synchronous)
      let p = source.promise

      p.flatMap { x -> Promise<Int, NSError> in
        calls += 1

        let s = PromiseSource<Int, NSError>(dispatch: .Synchronous)
        s.resolve(x + 1)
        return s.promise // Promise(value: x + 1)
      }
      .then { _ in
        calls += 2
      }

      source.resolve(42)

      XCTAssertEqual(calls, 3, "handler should have been called synchronously on current thread")
    }
  }

  func testSynchronousMapFinally() {
    expectation(backgroundQueue) {
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
  }

  func testSynchronousFlatMapFinally() {
    expectation(backgroundQueue) {
      var calls = 0

      let source = PromiseSource<Int, NSError>(dispatch: .Synchronous)
      let p = source.promise

      p.flatMap { x -> Promise<Int, NSError> in
        calls += 1

        let s = PromiseSource<Int, NSError>(dispatch: .Synchronous)
        s.resolve(x + 1)
        return s.promise // Promise(value: x + 1)
      }
      .finally {
        calls += 2
      }

      source.resolve(42)

      XCTAssertEqual(calls, 3, "handler should have been called synchronously on current thread")
    }
  }
}
