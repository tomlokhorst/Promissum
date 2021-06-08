//
//  AsyncAwaitTests.swift
//  PromissumTests
//
//  Created by Tom Lokhorst on 2021-03-06.
//

import XCTest
import Promissum

@available(macOS 12.0, *)
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

  func testGetResultSuccess() {
    withExpectiation(timeout: 0.1) {
      let r = await getFourPromise().getResult()
      XCTAssertEqual(r.value, 4)
    }
  }

  func testGetResultError() {
    withExpectiation(timeout: 0.1) {
      let r = await getErrorPromise().getResult()
      XCTAssertNotNil(r.error)
    }
  }

  func testAsyncInit() throws {
    var value: Int?

    let p = Promise {
      await getFourAsync()
    }

    p.then { x in
        value = x
      }

    XCTAssertNil(value)
    expectation(p) {
      XCTAssertEqual(value, 4)
    }
  }

  func testAsyncErrorInit() throws {
    var error: Error?

    let p = Promise {
      try await getErrorPromise().get()
    }

    p.trap { e in
        error = e
      }

    XCTAssertNil(error)
    expectation(p) {
      XCTAssertEqual((error as NSError?)?.code, 3)
    }
  }

  func testAsyncPotentialErrorInit() throws {
    var value: Int?

    let p = Promise {
      try await getFourErrorPromise().get()
    }

    p.then { x in
        value = x
      }

    XCTAssertNil(value)
    expectation(p) {
      XCTAssertEqual(value, 4)
    }
  }

  func withExpectiation(timeout: TimeInterval, operation: @escaping () async -> Void) {
    let ex = self.expectation(description: "Async call")
    async {
      await operation()
      ex.fulfill()
    }
    waitForExpectations(timeout: timeout)
  }
}

@available(macOS 12.0, *)
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
