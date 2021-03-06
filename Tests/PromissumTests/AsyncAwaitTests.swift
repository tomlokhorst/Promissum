//
//  AsyncAwaitTests.swift
//  PromissumTests
//
//  Created by Tom Lokhorst on 2021-03-06.
//

import XCTest
import Promissum
import _Concurrency

class AsyncAwaitTests: XCTestCase {


  func testThen() throws {
    var value: Int?

    let p = getFourPromise()
      .then { x in
        value = x
      }

    XCTAssertNil(value)
    expectation(p) {
      XCTAssertEqual(value, 4)
    }
  }

  func testAsync() {
    let ex = self.expectation(description: "Async call")
    var value: Int?

    makeCallback(operation: getFourAsync) { x in
      value = x

      XCTAssertEqual(value, 4)

      ex.fulfill()
    }
    XCTAssertNil(value)

    waitForExpectations(timeout: 0.1)
  }

  @asyncHandler func makeCallback<T>(operation: @escaping () async -> T, completion: @escaping (T) -> Void) {
    let value = await operation()
    completion(value)
  }

  func getFourAsync() async -> Int {
    return await withUnsafeContinuation { continuation in
      getFourPromise().finallyResult {
        continuation.resume(with: $0)
      }
    }
  }

  func getFourPromise() -> Promise<Int, Never> {
    Promise { source in
      DispatchQueue.main.async {
        source.resolve(4)
      }
    }
  }
}
