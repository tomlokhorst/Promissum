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
  
  func testUnresolvedSourceDeinit() {
    var deallocWarning = false
    
    makeUnresolvedPromise(deallocWarning: { _ in deallocWarning = true })
    
    XCTAssert(deallocWarning, "Dealloc warning callback should have been called")
  }
  
  func makeUnresolvedPromise(deallocWarning: @escaping ([SourceLocation]) -> Void) -> Promise<Int, NoError> {
    let source = PromiseSource<Int, NoError>()
    source.warnUnresolvedDeinit = Warning.callback(callstack: deallocWarning)
    
    return source.promise
  }
  
  func testUnresolvedMapDeinit() {
    var deallocWarning = false
    
    mappedPromise(deallocWarning: { _ in deallocWarning = true })
    
    XCTAssert(deallocWarning, "Dealloc warning callback should have been called")
  }
  
  func mappedPromise(deallocWarning: @escaping ([SourceLocation]) -> Void) -> Promise<Int, NoError> {
    return makeUnresolvedPromise(deallocWarning: deallocWarning).map { x in x * 2 }
  }
  
  func testUnresolvedVariableDeinit() {
    var deallocWarning = false
    
    var promise: Promise<Int, NoError>? = makeUnresolvedPromise(deallocWarning: { _ in deallocWarning = true })
    
    promise?.map { $0 }
    
    // Explicitly reset promise to trigger ARC dealloc of source at this point
    promise = nil
    
    XCTAssert(deallocWarning, "Dealloc warning callback should have been called")
  }
}
