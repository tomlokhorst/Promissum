//
//  AsyncAwaitTests.swift
//  PromissumTests
//
//  Created by Tom Lokhorst on 2021-03-06.
//

import XCTest
import Promissum

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
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

  func testAsync() async {
    let value = await getFourAsync()

    XCTAssertEqual(value, 4)
  }

  func testGetNoError() async {
    let value = await getFourPromise().asyncValue

    XCTAssertEqual(value, 4)
  }

  func testGetPotentialError() async throws {
    let value = try await getFourErrorPromise().asyncValue
    XCTAssertEqual(value, 4)
  }

  func testThrowGet() async {
    do {
      try await getErrorPromise().asyncValue
      XCTFail()
    } catch {
      XCTAssertNotNil(error)
    }
  }

  func testGetResultSuccess() async {
    let r = await getFourPromise().asyncResult
    XCTAssertEqual(r.value, 4)
  }

  func testGetResultError() async {
    let r = await getErrorPromise().asyncResult
    XCTAssertNotNil(r.error)
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
      try await getErrorPromise().asyncValue
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
      try await getFourErrorPromise().asyncValue
    }

    p.then { x in
        value = x
      }

    XCTAssertNil(value)
    expectation(p) {
      XCTAssertEqual(value, 4)
    }
  }
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
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
