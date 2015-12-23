//
//  SourceResultTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-02-08.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation

import Foundation
import XCTest
import Promissum

class SourceResultTests: XCTestCase {

  func testResult() {
    var result: Result<Int, NSError>?

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    result = p.result

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    XCTAssert(result == nil, "Result should be nil")
  }

  func testResultValue() {
    var result: Result<Int, NSError>?

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    p.finallyResult { r in
      result = r
    }

    source.resolve(42)

    expectation(p) {
      XCTAssert(result?.value == 42, "Result should be value")
    }
  }

  func testResultError() {
    var result: Result<Int, NSError>?

    let source = PromiseSource<Int, NSError>()
    let p = source.promise

    p.finallyResult { r in
      result = r
    }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    expectation(p) {
      XCTAssert(result?.error?.code == 42, "Result should be error")
    }
  }

  func testResultMapError() {
    var value: Int?

    let source = PromiseSource<Int, NSError>()
    let p: Promise<Int, NoError> = source.promise
      .mapResult { result in
        switch result {
        case .Error(let error):
          return .Value(error.code + 1)
        case .Value:
          return .Value(-1)
        }
      }

    p.then { x in
      value = x
    }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    expectation(p) {
      XCTAssert(value == 43, "Value should be set")
    }
  }


  func testResultMapValue() {
    var value: Int?

    let source = PromiseSource<Int, NSError>()
    let p: Promise<Int, NoError> = source.promise
      .mapResult { result in
        switch result {
        case .Value(let value):
          return .Value(value + 1)
        case .Error:
          return .Value(-1)
        }
    }

    p.then { x in
      value = x
    }

    source.resolve(42)

    expectation(p) {
      XCTAssert(value == 43, "Value should be set")
    }
  }

  func testResultFlatMapValueValue() {
    var value: Int?

    let source = PromiseSource<Int, NSError>()
    let p: Promise<Int, NSError> = source.promise
      .flatMapResult { result in
        switch result {
        case .Value(let value):
          return Promise(value: value + 1)
        case .Error:
          return Promise(value: -1)
        }
    }

    p.then { x in
      value = x
    }

    source.resolve(42)

    expectation(p) {
      XCTAssert(value == 43, "Value should be set")
    }
  }

  func testResultFlatMapValueError() {
    var error: NSError?

    let source = PromiseSource<Int, NSError>()
    let p: Promise<Int, NSError> = source.promise
      .flatMapResult { result in
        switch result {
        case .Value(let value):
          return Promise(error: NSError(domain: PromissumErrorDomain, code: value + 1, userInfo: nil))
        case .Error:
          return Promise(value: -1)
        }
    }

    p.trap { e in
      error = e
    }

    source.resolve(42)

    expectation(p) {
      XCTAssert(error?.code == 43, "Error should be set")
    }
  }

  func testResultFlatMapErrorValue() {
    var value: Int?

    let source = PromiseSource<Int, NSError>()
    let p: Promise<Int, NSError> = source.promise
      .flatMapResult { result in
        switch result {
        case .Error(let error):
          return Promise(value: error.code + 1)
        case .Value:
          return Promise(value: -1)
        }
    }

    p.then { x in
      value = x
    }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    expectation(p) {
      XCTAssert(value == 43, "Value should be set")
    }
  }

  func testResultFlatMapErrorError() {
    var error: NSError?

    let source = PromiseSource<Int, NSError>()
    let p: Promise<Int, NSError> = source.promise
      .flatMapResult { result in
        switch result {
        case .Error(let error):
          return Promise(error: NSError(domain: PromissumErrorDomain, code: error.code + 1, userInfo: nil))
        case .Value:
          return Promise(value: -1)
        }
    }

    p.trap { e in
      error = e
    }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    expectation(p) {
      XCTAssert(error?.code == 43, "Error should be set")
    }
  }
}
