//
//  State.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

public enum NoError {}

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
