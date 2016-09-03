//
//  ValueOrJsonError.swift
//  Statham
//
//  Created by Tom on 2016-07-18.
//  Copyright © 2016 nonstrict. All rights reserved.
//

import Foundation

public enum ValueOrJsonError<Wrapped> {
  case Value(Wrapped)
  case Error(JsonDecodeError)

  public var value: Wrapped? {
    switch self {
    case .Value(let val):
      return val

    case .Error:
      return nil
    }
  }

  public static func decodeJson(decodeWrapped: AnyObject throws -> Wrapped) -> AnyObject throws -> ValueOrJsonError<Wrapped> {
    return { json in
      do {
        return .Value(try decodeWrapped(json))
      }
      catch let error as JsonDecodeError {
        return .Error(error)
      }
    }
  }

  public func encodeJson(encodeJsonWrapped: Wrapped -> AnyObject) -> AnyObject {
    switch self {
    case .Value(let val):
      return encodeJsonWrapped(val)

    case .Error:
      return NSNull()
    }
  }
}
