//
//  AsyncExtensions.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2021-03-06.
//

import Foundation

@available(macOS 12.0, *)
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

@available(macOS 12.0, *)
extension Promise where Error == Swift.Error {
  public convenience init(block: @escaping () async throws -> Value) {
    let source = PromiseSource<Value, Error>()
    self.init(source: source)

    async {
      do {
        let value = try await block()
        source.resolve(value)
      } catch {
        source.reject(error)
      }
    }
  }
}

@available(macOS 12.0, *)
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

    async {
      let value = await block()
      source.resolve(value)
    }
  }

}
