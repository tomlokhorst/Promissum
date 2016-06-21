//
//  DispatchMethod.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-01-08.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation

public enum DispatchMethod {
  case unspecified
  case synchronous
  case onQueue(DispatchQueue)
}

extension DispatchMethod: CustomStringConvertible {

  public var description: String {
    switch self {
    case .unspecified:
      return "unspecified"
    case .synchronous:
      return "synchronous"
    case let .onQueue(dispatchQueue):
      return "onQueue(\(dispatchQueue))"
    }
  }
}
