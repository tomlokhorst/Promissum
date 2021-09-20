//
//  AsyncExtensions.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2021-03-06.
//

#if canImport(_Concurrency)

import Foundation

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension Promise {
  public var asyncValue: Value {
    get async throws {
      try await withUnsafeThrowingContinuation { continuation in
        self.finallyResult { result in
          continuation.resume(with: result)
        }
      }
    }
  }

  public var asyncResult: Result<Value, Error> {
    get async {
      await withUnsafeContinuation { continuation in
        self.finallyResult { result in
          continuation.resume(returning: result)
        }
      }
    }
  }
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension Promise where Error == Swift.Error {
  public convenience init(block: @escaping () async throws -> Value) {
    let source = PromiseSource<Value, Error>()
    self.init(source: source)

    Task {
      do {
        let value = try await block()
        source.resolve(value)
      } catch {
        source.reject(error)
      }
    }
  }
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension Promise where Error == Never {
  public var asyncValue: Value {
    get async {
      await withUnsafeContinuation { continuation in
        self.finallyResult { result in
          continuation.resume(with: result)
        }
      }
    }
  }

  public convenience init(block: @escaping () async -> Value) {
    let source = PromiseSource<Value, Never>()
    self.init(source: source)

    Task {
      let value = await block()
      source.resolve(value)
    }
  }

}

#endif
