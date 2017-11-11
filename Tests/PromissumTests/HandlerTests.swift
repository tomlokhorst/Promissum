//
//  HandlerTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2017-11-11.
//

import Foundation
import XCTest
import Promissum

private let testQueueLabel = "com.nonstrict.promissum.tests"
private let testQueue = DispatchQueue(label: testQueueLabel, attributes: [])
private let testQueueKey = DispatchSpecificKey<Void>()

class HandlerTests: XCTestCase {

  override func setUp() {
    testQueue.setSpecific(key: testQueueKey, value: ())
  }

  func testHandlerAdding() {
    var calls = 0

    let source = PromiseSource<Int, Error>()
    let p = source.promise

    p.then { _ in
      calls += 1

      p.then { _ in
        calls += 1
      }
    }

    source.resolve(42)

    self.expectation(p) {
      XCTAssertEqual(calls, 2)
    }
  }

  func testHandlerAddingUnspecifiedQueue() {
    var calls = 0

    let source = PromiseSource<Int, Error>()
    let p = source.promise

    p.then { _ in
      calls += 1

      var sameQueue = false

      p.then { _ in
        calls += 1

        sameQueue = true
      }

      XCTAssertTrue(sameQueue)
    }

    source.resolve(42)

    self.expectation(p) {
      XCTAssertEqual(calls, 2)
    }
  }

  func testHandlerAddingSynchronous() {
    var calls = 0

    let source = PromiseSource<Int, Error>(dispatch: .synchronous)
    let p = source.promise

    p.then { _ in
      calls += 1

      var sameQueue = false

      p.then { _ in
        calls += 1

        sameQueue = true
      }

      XCTAssertTrue(sameQueue)
    }

    source.resolve(42)

    self.expectation(p) {
      XCTAssertEqual(calls, 2)
    }
  }

  func testHandlerAddingMainQueue() {
    var calls = 0

    let source = PromiseSource<Int, Error>(dispatch: .queue(DispatchQueue.main))
    let p = source.promise

    p.then { _ in
      XCTAssertTrue(Thread.current.isMainThread)
      calls += 1

      var sameQueue = false

      p.then { _ in
        calls += 1

        sameQueue = true
      }

      XCTAssertTrue(sameQueue)
    }

    source.resolve(42)

    self.expectation(p) {
      XCTAssertEqual(calls, 2)
    }
  }

  func testHandlerAddingTestQueue() {
    var calls = 0

    let source = PromiseSource<Int, Error>(dispatch: .queue(testQueue))
    let p = source.promise

    p.then { _ in
      XCTAssertNotNil(DispatchQueue.getSpecific(key: testQueueKey), "callback for queued dispatch method should be called on specified queue")
      calls += 1

      var sameQueue = false

      p.then { _ in
        calls += 1

        sameQueue = true
      }

      XCTAssertTrue(sameQueue)
    }

    source.resolve(42)

    self.expectation(p) {
      XCTAssertEqual(calls, 2)
    }
  }
}
