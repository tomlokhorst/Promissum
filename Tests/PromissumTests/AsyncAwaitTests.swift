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
    withExpectiation(timeout: 0.1) {
      let value = await getFourAsync()

      XCTAssertEqual(value, 4)
    }
  }

  func testGetNoError() {
    withExpectiation(timeout: 0.1) {
      let value = await getFourPromise().get()

      XCTAssertEqual(value, 4)
    }
  }

  func testGetPotentialError() {
    withExpectiation(timeout: 0.1) {
      do {
        let value = try await getFourErrorPromise().get()
        XCTAssertEqual(value, 4)
      } catch {
        XCTFail()
      }
    }
  }

  func testThrowGet() {
    withExpectiation(timeout: 0.1) {
      do {
        try await getErrorPromise().get()
        XCTFail()
      } catch {
        XCTAssertNotNil(error)
      }
    }
  }

  func withExpectiation(timeout: TimeInterval, operation: @escaping () async -> Void) {
    let ex = self.expectation(description: "Async call")
    makeCallback(operation: operation) {
      ex.fulfill()
    }
    waitForExpectations(timeout: timeout)
  }

  @asyncHandler func makeCallback<T>(operation: @escaping () async -> T, completion: @escaping (T) -> Void) {
    let value = await operation()
    completion(value)
  }
}

private func getFourAsync() async -> Int {
  await withUnsafeContinuation { continuation in
    DispatchQueue.main.async {
      continuation.resume(returning: 4)
    }
  }
}

private func getFourPromise() -> Promise<Int, Never> {
  Promise { source in
    DispatchQueue.main.async {
      source.resolve(4)
    }
  }
}

private func getFourErrorPromise() -> Promise<Int, Error> {
  Promise { source in
    DispatchQueue.main.async {
      source.resolve(4)
    }
  }
}

private func getErrorPromise() -> Promise<Void, NSError> {
  Promise { source in
    DispatchQueue.main.async {
      source.reject(NSError(code: 3))
    }
  }
}

extension Promise {
  func get() async throws -> Value {
    try await withUnsafeThrowingContinuation { continuation in
      self.finallyResult { result in
        continuation.resume(with: result)
      }
    }
  }

  func getResult() async -> Result<Value, Error> {
    await withUnsafeContinuation { continuation in
      self.finallyResult { result in
        continuation.resume(returning: result)
      }
    }
  }

//  convenience init(block: () async throws -> Value) {
//    fatalError()
//  }
}

extension Promise where Error == Never {
  func get() async -> Value {
    await withUnsafeContinuation { continuation in
      self.finallyResult { result in
        continuation.resume(with: result)
      }
    }
  }
}
