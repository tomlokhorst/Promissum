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
  case value(TValue)
  case error(TError)

  /// Optional value, set when Result is Value.
  public var value: TValue? {
    switch self {
    case .value(let value):
      return value

    case .error:
      return nil
    }
  }

  /// Optional error, set when Result is Error.
  public var error: TError? {
    switch self {
    case .error(let error):
      return error

    case .value:
      return nil
    }
  }

  internal var state: State<TValue, TError> {
    switch self {
    case .value(let boxed):
      return .resolved(boxed)

    case .error(let error):
      return .rejected(error)
    }
  }
}

extension Result: CustomStringConvertible {

  public var description: String {
    switch self {
    case .value(let value):
      return "value(\(value))"

    case .error(let error):
      return "error(\(error))"
    }
  }
}
