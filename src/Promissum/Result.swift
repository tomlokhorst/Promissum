//
//  Result.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-01-07.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation

public enum Result<TValue, TError> {
  case Value(Box<TValue>)
  case Error(Box<TError>)

  public var value: TValue? {
    switch self {
    case .Value(let boxed):
      let value = boxed.unbox
      return value
    case .Error:
      return nil
    }
  }

  public var error: TError? {
    switch self {
    case .Error(let boxed):
      let error = boxed.unbox
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
      let value = boxed.unbox
      return "Value(\(value))"
    case .Error(let boxed):
      let error = boxed.unbox
      return "Error(\(error))"
    }
  }
}
