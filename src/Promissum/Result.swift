//
//  Result.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-01-07.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation

public enum Result<TValue, TError> {
  case Value(TValue)
  case Error(TError)

  public var value: TValue? {
    switch self {
    case .Value(let value):
      return value
    case .Error:
      return nil
    }
  }

  public var error: TError? {
    switch self {
    case .Error(let error):
      return error
    case .Value:
      return nil
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
