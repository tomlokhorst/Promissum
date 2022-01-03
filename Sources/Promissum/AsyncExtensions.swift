//
//  AsyncExtensions.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2021-03-06.
//

import Foundation

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Promise {

  /// Async property that returns the value of the promise when it is resolved, or throws when the promise is rejected.
  public var asyncValue: Value {
    get async throws {
#if canImport(_Concurrency)
      try await withUnsafeThrowingContinuation { continuation in
        self.finallyResult { result in
          continuation.resume(with: result)
        }
      }
#else
      fatalError()
#endif
    }
  }

  /// Async property that returns the result of a promise, when it is resolved or rejected.
  public var asyncResult: Result<Value, Error> {
    get async {
#if canImport(_Concurrency)
      await withUnsafeContinuation { continuation in
        self.finallyResult { result in
          continuation.resume(returning: result)
        }
      }
#else
      fatalError()
#endif
    }
  }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Promise where Error == Swift.Error {

  /// Initialize a Promise using an async closure that can throw an error.
  /// Used to transform an async function into a promise.
  ///
  /// Example:
  /// ```
  /// Promise {
  ///   try await myAsyncFunction()
  /// }
  /// ```
  public convenience init(block: @escaping () async throws -> Value) {
    let source = PromiseSource<Value, Error>()
    self.init(source: source)

#if canImport(_Concurrency)
    Task {
      do {
        let value = try await block()
        source.resolve(value)
      } catch {
        source.reject(error)
      }
    }
#else
      fatalError()
#endif
  }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Promise where Error == Never {

  /// Async property that returns the value of the promise when it is resolved.
  public var asyncValue: Value {
    get async {
#if canImport(_Concurrency)
      await withUnsafeContinuation { continuation in
        self.finallyResult { result in
          continuation.resume(with: result)
        }
      }
#else
      fatalError()
#endif
    }
  }

  /// Initialize a Promise using an async closure.
  /// Used to transform an async function into a promise.
  ///
  /// Example:
  /// ```
  /// Promise {
  ///   await myAsyncFunction()
  /// }
  /// ```
  public convenience init(block: @escaping () async -> Value) {
    let source = PromiseSource<Value, Never>()
    self.init(source: source)

#if canImport(_Concurrency)
    Task {
      let value = await block()
      source.resolve(value)
    }
#else
      fatalError()
#endif
  }

}
