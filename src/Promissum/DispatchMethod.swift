//
//  DispatchMethod.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-01-08.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation

public enum DispatchMethod {
  case Unspecified
  case Synchronous
  case OnQueue(dispatch_queue_t)
}

extension DispatchMethod: CustomStringConvertible {

  public var description: String {
    switch self {
    case .Unspecified:
      return "Unspecified"
    case .Synchronous:
      return "Synchronous"
    case let .OnQueue(dispatchQueue):
      return "OnQueue(\(dispatchQueue))"
    }
  }
}
