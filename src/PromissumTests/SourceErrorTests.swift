//
//  SourceErrorTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-12-31.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

class SourceErrorTests: XCTestCase {

  func testError() {
    var error: NSError?

    let source = PromiseSource<Int>()
    let p = source.promise

    error = p.error()

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    XCTAssert(error?.code == nil, "Error should be nil")
  }

  func testErrorVoid() {
    var error: NSError?

    let source = PromiseSource<Int>()
    let p = source.promise

    p.catch { e in
      error = e
    }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    XCTAssert(error?.code == 42, "Error should be set")
  }

  func testErrorMap() {
    var value: Int?

    let source = PromiseSource<Int>()
    let p = source.promise
      .mapError { $0.code + 1 }

    p.then { x in
      value = x
    }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    XCTAssert(value == 43, "Value should be set")
  }

  func testErrorFlatMap() {
    var value: Int?

    let source = PromiseSource<Int>()
    let p = source.promise
      .flatMapError { Promise(value: $0.code + 1) }

    p.then { x in
      value = x
    }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    XCTAssert(value == 43, "Value should be set")
  }

  func testErrorFlatMap2() {
    var error: NSError?

    let source = PromiseSource<Int>()
    let p = source.promise
      .flatMapError { Promise(error: NSError(domain: PromissumErrorDomain, code: $0.code + 1, userInfo: nil)) }

    p.catch { e in
      error = e
    }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    XCTAssert(error?.code == 43, "Error should be set")
  }

  func testFinally() {
    var finally: Bool = false

    let source = PromiseSource<Int>()
    let p = source.promise

    p.finally {
      finally = true
    }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    XCTAssert(finally, "Finally should be set")
  }
}
