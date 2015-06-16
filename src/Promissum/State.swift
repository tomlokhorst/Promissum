//
//  State.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

public enum State<T> {
  case Unresolved(PromiseSource<T>)
  case Resolved(T)
  case Rejected(NSError)
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
