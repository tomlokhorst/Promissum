//
//  PromiseSource.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

// This Notifier is used to implement Promise.map
public protocol PromiseNotifier {
  func registerHandler(handler: () -> Void)
}

public class PromiseSource<Value, Error> {
  typealias ResultHandler = Result<Value, Error> -> Void
  public var promise: Promise<Value, Error>!
  public var warnUnresolvedDeinit: Bool

  private var handlers: [Result<Value, Error> -> Void] = []

  private let originalPromise: PromiseNotifier?

  public convenience init(warnUnresolvedDeinit: Bool = true) {
    self.init(originalPromise: nil, warnUnresolvedDeinit: warnUnresolvedDeinit)
  }

  public init(originalPromise: PromiseNotifier?, warnUnresolvedDeinit: Bool) {
    self.originalPromise = originalPromise
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

  public func resolve(value: Value) {

    switch promise.state {
    case State<Value, Error>.Unresolved:
      promise.state = State<Value, Error>.Resolved(Box(value))

      executeResultHandlers(.Value(Box(value)))
    default:
      break
    }
  }

  public func reject(error: Error) {

    switch promise.state {
    case State<Value, Error>.Unresolved:
      promise.state = State<Value, Error>.Rejected(Box(error))

      executeResultHandlers(.Error(Box(error)))
    default:
      break
    }
  }

  internal func addHander(handler: Result<Value, Error> -> Void) {
    if let originalPromise = originalPromise {
      originalPromise.registerHandler({
        self.promise.addResultHandler(handler)
      })
    }
    else {
      handlers.append(handler)
    }
  }

  private func executeResultHandlers(result: Result<Value, Error>) {

    // Call all previously scheduled handlers
    callHandlers(result, handlers)

    // Cleanup
    handlers = []
  }
}

internal func callHandlers<T>(arg: T, handlers: [T -> Void]) {
  for handler in handlers {
    handler(arg)
  }
}
