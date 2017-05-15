//
//  InitialErrorTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-12-31.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

let PromissumErrorDomain = "com.nonstrict.Promissum"

extension NSError {
  convenience init(code: Int) {
    self.init(domain: PromissumErrorDomain, code: code, userInfo: nil)
  }
}

class InitialErrorTests: XCTestCase {

  func testError() {
    var error: NSError?

    let p = Promise<Int, NSError>(error: NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    error = p.error

    XCTAssert(error?.code == 42, "Error should be set")
  }

  func testErrorVoid() {
    var error: NSError?

    let p = Promise<Int, NSError>(error: NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    p.trap { e in
      error = e
    }

    expectation(p) {
      XCTAssert(error?.code == 42, "Error should be set")
    }
  }

  func testErrorMap() {
    var value: Int?

    let p = Promise<Int, NSError>(error: NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))
      .mapError { $0.code + 1 }

    p.trap { x in
      value = x
    }

    expectation(p) {
      XCTAssert(value == 43, "Value should be set")
    }
  }

  func testErrorFlatMap() {
    var value: Int?

    let p = Promise<Int, NSError>(error: NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))
      .flatMapError { Promise<Int, String>(value: $0.code + 1) }

    p.then { x in
      value = x
    }

    expectation(p) {
      XCTAssert(value == 43, "Value should be set")
    }
  }

  func testErrorFlatMap2() {
    var error: NSError?

    let p = Promise<Int, NSError>(error: NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))
      .flatMapError { Promise(error: NSError(domain: PromissumErrorDomain, code: $0.code + 1, userInfo: nil)) }

    p.trap { e in
      error = e
    }

    expectation(p) {
      XCTAssert(error?.code == 43, "Error should be set")
    }
  }

  func testFinally() {
    var finally: Bool = false

    let p = Promise<Int, NSError>(error: NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    p.finally {
      finally = true
    }

    expectation(p) {
      XCTAssert(finally, "Finally should be set")
    }
  }
}
