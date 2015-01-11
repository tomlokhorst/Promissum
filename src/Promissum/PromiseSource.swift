//
//  PromiseSource.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

public class PromiseSource<T> {
  public let promise: Promise<T>!
  public var warnUnresolvedDeinit: Bool

  internal var resolvedHandlers: [T -> Void] = []
  internal var errorHandlers: [NSError -> Void] = []

  public init(warnUnresolvedDeinit: Bool = true) {
    self.warnUnresolvedDeinit = warnUnresolvedDeinit

    self.promise = Promise(source: self)
  }

  deinit {
    if warnUnresolvedDeinit {
      switch promise.state {
      case .Unresolved:
        println("PromiseSource.deinit: WARNING: Unresolved PromiseSource deallocated, maybe retain this object?")
      default:
        break
      }
    }
  }

  public func resolve(value: T) {

    switch promise.state {
    case State<T>.Unresolved:
      promise.state = State<T>.Resolved(value)

      executeResolvedHandlers(value)
    default:
      break
    }
  }

  public func reject(error: NSError) {

    switch promise.state {
    case State<T>.Unresolved:
      promise.state = State<T>.Rejected(error)

      executeErrorHandlers(error)
    default:
      break
    }
  }

  private func executeResolvedHandlers(value: T) {

    // Call all previously scheduled handlers
    callHandlers(value, resolvedHandlers)

    // Cleanup
    resolvedHandlers = []
    errorHandlers = []
  }

  private func executeErrorHandlers(error: NSError) {

    // Call all previously scheduled handlers
    callHandlers(error, errorHandlers)

    // Cleanup
    resolvedHandlers = []
    errorHandlers = []
  }
}

internal func callHandlers<T>(arg: T, handlers: [T -> Void]) {
  for handler in handlers {
    handler(arg)
  }
}
