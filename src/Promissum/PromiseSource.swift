//
//  PromiseSource.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

public class PromiseSource<T> {
  public let promise: Promise<T>
  public var warnUnresolvedDeinit: Bool

  public init(warnUnresolvedDeinit: Bool = true) {
    self.promise = Promise<T>()
    self.warnUnresolvedDeinit = warnUnresolvedDeinit
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
    self.promise.tryResolve(value)
  }

  public func reject(error: NSError) {
    self.promise.tryReject(error)
  }
}
