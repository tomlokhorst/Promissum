//
//  Result.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-01-07.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation

/// The Result type is used for Promises that are Resolved or Rejected.
extension Result {

  /// Optional value, set when Result is Value.
  public var value: Success? {
    switch self {
    case .success(let value):
      return value
    case .failure:
      return nil
    }
  }

  /// Optional error, set when Result is Error.
  public var error: Failure? {
    switch self {
    case .failure(let error):
      return error
    case .success:
      return nil
    }
  }

  internal var state: State<Success, Failure> {
    switch self {
    case .success(let boxed):
      return .resolved(boxed)

    case .failure(let error):
      return .rejected(error)
    }
  }
}
