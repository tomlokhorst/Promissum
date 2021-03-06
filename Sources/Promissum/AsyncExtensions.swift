//
//  AsyncExtensions.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2021-03-06.
//

import Foundation
import _Concurrency

extension Promise {
  public func get() async throws -> Value {
    try await withUnsafeThrowingContinuation { continuation in
      self.finallyResult { result in
        continuation.resume(with: result)
      }
    }
  }

  public func getResult() async -> Result<Value, Error> {
    await withUnsafeContinuation { continuation in
      self.finallyResult { result in
        continuation.resume(returning: result)
      }
    }
  }
}

extension Promise where Error == Swift.Error {
  public convenience init(block: @escaping () async throws -> Value) {
    let source = PromiseSource<Value, Error>()
    self.init(source: source)

    Task.runDetached {
      do {
        let value = try await block()
        source.resolve(value)
      } catch {
        source.reject(error)
      }
    }
  }
}

extension Promise where Error == Never {
  public func get() async -> Value {
    await withUnsafeContinuation { continuation in
      self.finallyResult { result in
        continuation.resume(with: result)
      }
    }
  }

  public convenience init(block: @escaping () async -> Value) {
    let source = PromiseSource<Value, Never>()
    self.init(source: source)

    Task.runDetached {
      let value = await block()
      source.resolve(value)
    }
  }

}

//@asyncHandler private func runAsync(operation: @escaping () async -> Void) {
//  await operation()
//}
