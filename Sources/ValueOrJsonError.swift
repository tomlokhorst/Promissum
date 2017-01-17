//
//  ValueOrJsonError.swift
//  Statham
//
//  Created by Tom on 2016-07-18.
//  Copyright © 2016 nonstrict. All rights reserved.
//

import Foundation

public enum ValueOrJsonError<Wrapped> {
  case value(Wrapped)
  case error(JsonDecodeError)

  public var value: Wrapped? {
    switch self {
    case .value(let val):
      return val

    case .error:
      return nil
    }
  }

  public static func decodeJson(_ decodeWrapped: @escaping (Any) throws -> Wrapped) -> (Any) throws -> ValueOrJsonError<Wrapped> {
    return { json in
      do {
        return .value(try decodeWrapped(json))
      }
      catch let error as JsonDecodeError {
        return .error(error)
      }
    }
  }

  public func encodeJson(_ encodeJsonWrapped: (Wrapped) -> Any) -> Any {
    switch self {
    case .value(let val):
      return encodeJsonWrapped(val)

    case .error:
      return NSNull()
    }
  }
}
