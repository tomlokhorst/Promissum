//
//  ResolveRejectTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-12-31.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

class ResolveRejectTests: XCTestCase {

  func testResolveReject() {
    var state = ""

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    p.then { _ in
      state = "resolved"
    }
    p.trap { _ in
      state = "rejected"
    }

    source.resolve(42)
    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    expectation(p) {
      XCTAssertEqual(state, "resolved", "State should be resolved")
    }
  }

  func testRejectResolve() {
    var state = ""

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    p.then { _ in
      state = "resolved"
    }
    p.trap { _ in
      state = "rejected"
    }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))
    source.resolve(42)

    expectation(p) {
      XCTAssertEqual(state, "rejected", "State should be rejected")
    }
  }

  func testResolveFinally() {
    var state = ""

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    p.then { _ in
      state = "resolved"
    }
    p.finally {
      state = "finally"
    }

    source.resolve(42)

    expectation(p) {
      XCTAssertEqual(state, "finally", "State should be finally")
    }
  }

  func testFinallyResolve() {
    var state = ""

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    p.finally {
      state = "finally"
    }
    p.then { _ in
      state = "resolved"
    }

    source.resolve(42)

    expectation(p) {
      XCTAssertEqual(state, "resolved", "State should be resolved")
    }
  }
}
