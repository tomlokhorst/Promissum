//
//  JsonDecodable.swift
//  Statham
//
//  Created by Tom Lokhorst on 2016-02-20.
//  Copyright © 2016 nonstrict. All rights reserved.
//

import Foundation

class JsonDecoder {
  var errors: [(String, JsonDecodeError)] = []
  let dict: [String : AnyObject]

  init(json: AnyObject) throws {

    guard let dict = json as? [String : AnyObject] else {
      self.dict = [:] // Init field, for Swift 2.0
      throw JsonDecodeError.WrongType(rawValue: json, expectedType: "Object")
    }

    self.dict = dict
  }

  func decode<T>(name: String, decoder: AnyObject throws -> T) throws -> T? {

    if let field: AnyObject = dict[name] {
      do {
        return try decoder(field)
      }
      catch let error as JsonDecodeError {
        errors.append((name, error))
      }
    }
    else {
      errors.append((name, JsonDecodeError.MissingField))
    }

    return nil
  }

  func decode<T>(name: String, decoder: AnyObject throws -> T?) throws -> T?? {

    if let field: AnyObject = dict[name] {
      do {
        return try decoder(field)
      }
      catch let error as JsonDecodeError {
        errors.append((name, error))
      }
    }
    else {
      return .Some(nil)
    }

    return nil
  }
}
