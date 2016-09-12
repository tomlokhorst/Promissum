//
//  JsonDecodable.swift
//  Statham
//
//  Created by Tom Lokhorst on 2016-02-20.
//  Copyright © 2016 nonstrict. All rights reserved.
//

import Foundation

public class JsonDecoder {
  public var errors: [(String, JsonDecodeError)] = []

  private let dict: [String : Any]

  public init(json: Any) throws {

    guard let dict = json as? [String : Any] else {
      throw JsonDecodeError.wrongType(rawValue: json, expectedType: "Object")
    }

    self.dict = dict
  }

  public func decode<T>(_ name: String, decoder: (Any) throws -> T) throws -> T? {

    if let field = dict[name] {
      do {
        return try decoder(field)
      }
      catch let error as JsonDecodeError {
        errors.append((name, error))
      }
    }
    else {
      errors.append((name, JsonDecodeError.missingField))
    }

    return nil
  }

  public func decode<T>(_ name: String, decoder: (Any) throws -> T?) throws -> T?? {

    if let field = dict[name] {
      do {
        return try decoder(field)
      }
      catch let error as JsonDecodeError {
        errors.append((name, error))
      }
    }
    else {
      return .some(nil)
    }

    return nil
  }
}
