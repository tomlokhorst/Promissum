//
//  Result.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-01-07.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation

public class Box<T> {
  public let unbox: T
  public init(_ value: T) { self.unbox = value }
}

public enum Result<T> {
  case Value(Box<T>)
  case Error(NSError)

  public func value() -> T? {
    switch self {
    case .Value(let boxed):
      let val = boxed.unbox
      return val
    case .Error:
      return nil
    }
  }

  public func error() -> NSError? {
    switch self {
    case .Error(let error):
      return error
    case .Value:
      return nil
    }
  }
}

extension Result: Printable {

  public var description: String {
    switch self {
    case .Value(let boxed):
      let val = boxed.unbox
      return "Value(\(val))"
    case .Error(let error):
      return "Error(\(error))"
    }
  }
}
