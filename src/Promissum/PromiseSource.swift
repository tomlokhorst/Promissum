//
//  PromiseSource.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

public class PromiseSource<T> {
  public typealias ResolveHandler = T -> Void
  public typealias ErrorHandler = NSError -> Void

  public let promise: Promise<T>!
  public var warnUnresolvedDeinit: Bool

  private var resolvedHandlers: [ResolveHandler] = []
  private var errorHandlers: [ErrorHandler] = []

  private let onThenHandler: ((Promise<T>, ResolveHandler) -> Void)?
  private let onCatchHandler: ((Promise<T>, ErrorHandler) -> Void)?

  public convenience init(warnUnresolvedDeinit: Bool = true) {
    self.init(onThenHandler: nil, onCatchHandler: nil, warnUnresolvedDeinit: warnUnresolvedDeinit)
  }

  public init(onThenHandler: ((Promise<T>, ResolveHandler) -> Void)?, onCatchHandler: ((Promise<T>, ErrorHandler) -> Void)?, warnUnresolvedDeinit: Bool) {
    self.onThenHandler = onThenHandler
    self.onCatchHandler = onCatchHandler
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
      promise.state = State<T>.Resolved(Box(value))

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

  internal func addResolvedHander(handler: ResolveHandler) {
    if let onThenHandler = onThenHandler {
      onThenHandler(promise, handler)
    }
    else {
      resolvedHandlers.append(handler)
    }
  }

  internal func addErrorHandler(handler: ErrorHandler) {
    if let onCatchHandler = onCatchHandler {
      onCatchHandler(promise, handler)
    }
    else {
      errorHandlers.append(handler)
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
