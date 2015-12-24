//
//  Result.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-01-07.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation

/// The Result type is used for Promises that are Resolved or Rejected.
public enum Result<TValue, TError> {
  case Value(TValue)
  case Error(TError)

  /// Optional value, set when Result is Value.
  public var value: TValue? {
    switch self {
    case .Value(let value):
      return value
    case .Error:
      return nil
    }
  }

  /// Optional error, set when Result is Error.
  public var error: TError? {
    switch self {
    case .Error(let error):
      return error
    case .Value:
      return nil
    }
  }

  internal var state: State<TValue, TError> {
    switch self {
    case .Value(let boxed):
      return .Resolved(boxed)
    case .Error(let error):
      return .Rejected(error)
    }
  }
}

extension Result: CustomStringConvertible {

  public var description: String {
    switch self {
    case .Value(let value):
      return "Value(\(value))"
    case .Error(let error):
      return "Error(\(error))"
    }
  }
}
