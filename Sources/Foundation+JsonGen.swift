//
//  Foundation+JsonGen.swift
//  Statham
//
//  Created by Tom Lokhorst on 2016-02-20.
//  Copyright © 2016 nonstrict. All rights reserved.
//

import Foundation

extension String {
  public static func decodeJson(json: AnyObject) throws -> String {
    guard let result = json as? String else {
      throw JsonDecodeError.WrongType(rawValue: json, expectedType: "String")
    }

    return result
  }

  public func encodeJson() -> String {
    return self
  }
}

extension Bool {
  public static func decodeJson(json: AnyObject) throws -> Bool {
    guard let result = json as? Bool else {
      throw JsonDecodeError.WrongType(rawValue: json, expectedType: "Bool")
    }

    return result
  }

  public func encodeJson() -> Bool {
    return self
  }
}

extension Int {
  public static func decodeJson(json: AnyObject) throws -> Int {
    guard let result = json as? Int else {
      throw JsonDecodeError.WrongType(rawValue: json, expectedType: "Int")
    }

    return result
  }

  public func encodeJson() -> Int {
    return self
  }
}

extension UInt {
  public static func decodeJson(json: AnyObject) throws -> UInt {
    guard let result = json as? UInt else {
      throw JsonDecodeError.WrongType(rawValue: json, expectedType: "UInt")
    }

    return result
  }

  public func encodeJson() -> UInt {
    return self
  }
}

extension Int64 {
  public static func decodeJson(json: AnyObject) throws -> Int64 {
    guard let number = json as? NSNumber else {
      throw JsonDecodeError.WrongType(rawValue: json, expectedType: "Int64")
    }

    return number.longLongValue
  }

  public func encodeJson() -> NSNumber {
    return NSNumber(longLong: self)
  }
}

extension Float {
  public static func decodeJson(json : AnyObject) throws -> Float {
    guard let number = json as? NSNumber else {
      throw JsonDecodeError.WrongType(rawValue: json, expectedType: "Float")
    }

    return number.floatValue
  }

  public func encodeJson() -> Float {
    return self
  }
}

extension Double {
  public static func decodeJson(json : AnyObject) throws -> Double {
    guard let number = json as? NSNumber else {
      throw JsonDecodeError.WrongType(rawValue: json, expectedType: "Double")
    }

    return number.doubleValue
  }

  public func encodeJson() -> Double {
    return self
  }
}

extension NSDictionary {
  public static func decodeJson(json: AnyObject) throws -> NSDictionary {
    guard let result = json as? NSDictionary else {
      throw JsonDecodeError.WrongType(rawValue: json, expectedType: "NSDictionary")
    }

    return result
  }

  public func encodeJson() -> NSDictionary {
    return self
  }
}

extension NSURL {
  public static func decodeJson(json: AnyObject) throws -> NSURL {
    guard let str = json as? String,
      let result = NSURL(string: str)
      else {
        throw JsonDecodeError.WrongType(rawValue: json, expectedType: "NSURL")
    }

    return result
  }

  public func encodeJson() -> NSObject {
    return self.absoluteString ?? NSNull()
  }
}

extension Optional {
  public static func decodeJson(decodeWrapped: AnyObject throws -> Wrapped) -> AnyObject throws -> Wrapped? {
    return { json in
      if json is NSNull {
        return nil
      }

      do {
        return try decodeWrapped(json)
      }
      catch let error as JsonDecodeError {
        if case let .WrongType(rawValue: rawValue, expectedType: expectedType) = error {
          throw JsonDecodeError.WrongType(rawValue: rawValue, expectedType: "\(expectedType)?")
        }

        throw error
      }
    }
  }

  public func encodeJson(encodeJsonWrapped: Wrapped -> AnyObject) -> AnyObject {
    return self.map(encodeJsonWrapped) ?? NSNull()
  }
}

extension Array {
  public static func decodeJson(decodeElement: AnyObject throws -> Element) -> AnyObject throws -> [Element] {
    return { json in
      guard let arr = json as? [AnyObject] else {
        throw JsonDecodeError.WrongType(rawValue: json, expectedType: "Array")
      }

      var errors: [(Int, JsonDecodeError)] = []
      var result: [Element] = []

      for (index, element) in arr.enumerate() {
        do {
          result.append(try decodeElement(element))
        }
        catch let error as JsonDecodeError {
          errors.append((index, error))
        }
      }

      if errors.count > 0 {
        throw JsonDecodeError.ArrayElementErrors(errors)
      }

      return result
    }
  }

  public func encodeJson(encodeJsonElement: Element -> AnyObject) -> [AnyObject] {
    return self.map(encodeJsonElement)
  }
}

extension Dictionary {
  public static func decodeJson(decodeKey: AnyObject throws -> Key, _ decodeValue: AnyObject throws -> Value) -> AnyObject throws -> [Key: Value] {
    return { json in
      guard let dict = json as? [Key: AnyObject] else {
        throw JsonDecodeError.WrongType(rawValue: json, expectedType: "Dictionary")
      }

      var errors: [(String, JsonDecodeError)] = []
      var result: [Key: Value] = [:]

      for (key, val) in dict {
        do {
          result[key] = try decodeValue(val)
        }
        catch let error as JsonDecodeError {
          errors.append(("\(key)", error))
        }
      }

      if errors.count > 0 {
        throw JsonDecodeError.DictionaryErrors(errors)
      }

      return result
    }
  }

  public func encodeJson(encodeJsonKey: Key -> String, _ encodeJsonValue: Value -> AnyObject) -> [String: AnyObject] {
    var dict: [String: AnyObject] = [:]

    for (key, val) in self {
      let keyString = encodeJsonKey(key)
      dict[keyString] = encodeJsonValue(val)
    }

    for (key, value) in self {
      dict[encodeJsonKey(key)] = encodeJsonValue(value)
    }

    return dict
  }
}

// JsonObject
extension SequenceType where Generator.Element == (String, AnyObject) {
  public static func decodeJson(json: AnyObject) throws -> JsonObject {
    guard let result = json as? JsonObject else {
      throw JsonDecodeError.WrongType(rawValue: json, expectedType: "JsonObject")
    }

    return result
  }

  public func encodeJson() -> [String: AnyObject] {
    var dict: [String: AnyObject] = [:]

    for (key, val) in self {
      dict[key] = val
    }

    return dict
  }
}

// JsonArray
extension SequenceType where Generator.Element == AnyObject {
  public static func decodeJson(json: AnyObject) throws -> JsonArray {
    guard let result = json as? JsonArray else {
      throw JsonDecodeError.WrongType(rawValue: json, expectedType: "JsonArray")
    }

    return result
  }

  public func encodeJson() -> [AnyObject] {
    return Array(self)
  }
}
