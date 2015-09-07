//
//  State.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

/// Type used when there is no error possible.
public enum NoError : ErrorType {}

/// State of a PromiseSource.
public enum State<Value, Error> {
  case Unresolved
  case Resolved(Value)
  case Rejected(Error)
}

extension State: CustomStringConvertible {

  public var description: String {
    switch self {
    case .Unresolved:
      return "Unresolved"
    case .Resolved(let value):
      return "Resolved(\(value))"
    case .Rejected(let error):
      return "Rejected(\(error))"
    }
  }
}
