//
//  DeinitWarningTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 03/12/15.
//  Copyright © 2015 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

class DeinitWarningTests: XCTestCase {

  func makeUnresolvedPromise(deallocWarning: @escaping (Callstack) -> Void) -> Promise<Int, NoError> {
    let source = PromiseSource<Int, NoError>()
    source.warnUnresolvedDeinit = Warning.callback(deallocWarning)

    return source.promise
  }

  func mappedPromise(deallocWarning: @escaping (Callstack) -> Void) -> Promise<Int, NoError> {
    return makeUnresolvedPromise(deallocWarning: deallocWarning).map { x in x * 2 }
  }

  func testUnresolvedSourceDeinit() {
    var callstack: Callstack?

    _ = makeUnresolvedPromise(deallocWarning: { callstack = $0 })

    XCTAssertEqual(callstack?.locations.count, 1)
    XCTAssertEqual(callstack?.locations.first?.function, "makeUnresolvedPromise(deallocWarning:)")
  }
  
  func testUnresolvedMapDeinit() {
    var callstack: Callstack?
    
    _ = mappedPromise(deallocWarning: { callstack = $0 })

    XCTAssertEqual(callstack?.locations.count, 2)
    XCTAssertEqual(callstack?.locations.first?.function, "makeUnresolvedPromise(deallocWarning:)")
    XCTAssertEqual(callstack?.locations.last?.function, "mappedPromise(deallocWarning:)")
  }
  
  func testUnresolvedVariableDeinit() {
    var callstack: Callstack?
    
    var promise: Promise<Int, NoError>? = makeUnresolvedPromise(deallocWarning: { callstack = $0 })

    _ = promise?.map { $0 }
    
    // Explicitly reset promise to trigger ARC dealloc of source at this point
    promise = nil

    XCTAssertEqual(callstack?.locations.count, 2)
    XCTAssertEqual(callstack?.locations.first?.function, "makeUnresolvedPromise(deallocWarning:)")
    XCTAssertEqual(callstack?.locations.last?.function, "testUnresolvedVariableDeinit()")
  }
}
