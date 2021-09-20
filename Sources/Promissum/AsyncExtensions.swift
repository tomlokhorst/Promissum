//
//  AsyncExtensions.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2021-03-06.
//

import Foundation

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension Promise {
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

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension Promise where Error == Swift.Error {
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

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension Promise where Error == Never {
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
