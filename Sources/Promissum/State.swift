//
//  State.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

/// Type used when there is no error possible.
public enum NoError : Error {}

/// State of a PromiseSource.
public enum State<Value, Error> {
  case unresolved
  case resolved(Value)
  case rejected(Error)
}

extension State: CustomStringConvertible {

  public var description: String {
    switch self {
    case .unresolved:
      return "Unresolved"

    case .resolved(let value):
      return "Resolved(\(value))"

    case .rejected(let error):
      return "Rejected(\(error))"
    }
  }
}
