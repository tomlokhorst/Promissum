//
//  State.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

public class Box<T> {
  public let unbox: T
  public init(_ value: T) { self.unbox = value }
}

public enum NoError { }

public enum State<Value, Error> {
  case Unresolved(PromiseSource<Value, Error>)
  case Resolved(Box<Value>)
  case Rejected(Box<Error>)
}

extension State: Printable {

  public var description: String {
    switch self {
    case .Unresolved:
      return "Unresolved"
    case .Resolved(let boxed):
      let value = boxed.unbox
      return "Resolved(\(value))"
    case .Rejected(let boxed):
      let error = boxed.unbox
      return "Rejected(\(error))"
    }
  }
}
