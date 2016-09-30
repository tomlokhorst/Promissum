//
//  Foundation+JsonGen.swift
//  Statham
//
//  Created by Tom Lokhorst on 2016-02-20.
//  Copyright © 2016 nonstrict. All rights reserved.
//

import Foundation

extension String {
  public static func decodeJson(_ json: Any) throws -> String {
    guard let result = json as? String else {
      throw JsonDecodeError.wrongType(rawValue: json, expectedType: "String")
    }

    return result
  }

  public func encodeJson() -> String {
    return self
  }
}

extension Bool {
  public static func decodeJson(_ json: Any) throws -> Bool {
    guard let result = json as? Bool else {
      throw JsonDecodeError.wrongType(rawValue: json, expectedType: "Bool")
    }

    return result
  }

  public func encodeJson() -> Bool {
    return self
  }
}

extension Int {
  public static func decodeJson(_ json: Any) throws -> Int {
    guard let result = json as? Int else {
      throw JsonDecodeError.wrongType(rawValue: json, expectedType: "Int")
    }

    return result
  }

  public func encodeJson() -> Int {
    return self
  }
}

extension UInt {
  public static func decodeJson(_ json: Any) throws -> UInt {
    guard let result = json as? UInt else {
      throw JsonDecodeError.wrongType(rawValue: json, expectedType: "UInt")
    }

    return result
  }

  public func encodeJson() -> UInt {
    return self
  }
}

extension Int64 {
  public static func decodeJson(_ json: Any) throws -> Int64 {
    guard let number = json as? NSNumber else {
      throw JsonDecodeError.wrongType(rawValue: json, expectedType: "Int64")
    }

    return number.int64Value
  }

  public func encodeJson() -> NSNumber {
    return NSNumber(value: self)
  }
}

extension Float {
  public static func decodeJson(_ json : Any) throws -> Float {
    guard let number = json as? NSNumber else {
      throw JsonDecodeError.wrongType(rawValue: json, expectedType: "Float")
    }

    return number.floatValue
  }

  public func encodeJson() -> Float {
    return self
  }
}

extension Double {
  public static func decodeJson(_ json : Any) throws -> Double {
    guard let number = json as? NSNumber else {
      throw JsonDecodeError.wrongType(rawValue: json, expectedType: "Double")
    }

    return number.doubleValue
  }

  public func encodeJson() -> Double {
    return self
  }
}

extension NSDictionary {
  public static func decodeJson(_ json: Any) throws -> NSDictionary {
    guard let result = json as? NSDictionary else {
      throw JsonDecodeError.wrongType(rawValue: json, expectedType: "NSDictionary")
    }

    return result
  }

  public func encodeJson() -> NSDictionary {
    return self
  }
}

extension URL {
  public static func decodeJson(_ json: Any) throws -> URL {
    guard let str = json as? String,
      let result = URL(string: str)
      else {
        throw JsonDecodeError.wrongType(rawValue: json, expectedType: "NSURL")
    }

    return result
  }

  public func encodeJson() -> NSObject {
    return self.absoluteString as NSString
  }
}

extension Optional {
  public static func decodeJson(_ decodeWrapped: @escaping (Any) throws -> Wrapped) -> (Any) throws -> Wrapped? {
    return { json in
      if json is NSNull {
        return nil
      }

      do {
        return try decodeWrapped(json)
      }
      catch let error as JsonDecodeError {
        if case let .wrongType(rawValue: rawValue, expectedType: expectedType) = error {
          throw JsonDecodeError.wrongType(rawValue: rawValue, expectedType: "\(expectedType)?")
        }

        throw error
      }
    }
  }

  public func encodeJson(_ encodeJsonWrapped: (Wrapped) -> Any) -> Any {
    return self.map(encodeJsonWrapped) ?? NSNull()
  }
}

extension Array {
  public static func decodeJson(_ decodeElement: @escaping (Any) throws -> Element) -> (Any) throws -> [Element] {
    return { json in
      guard let arr = json as? [Any] else {
        throw JsonDecodeError.wrongType(rawValue: json, expectedType: "Array")
      }

      var errors: [(Int, JsonDecodeError)] = []
      var result: [Element] = []

      for (index, element) in arr.enumerated() {
        do {
          result.append(try decodeElement(element))
        }
        catch let error as JsonDecodeError {
          errors.append((index, error))
        }
      }

      if errors.count > 0 {
        throw JsonDecodeError.arrayElementErrors(errors)
      }

      return result
    }
  }

  public func encodeJson(_ encodeJsonElement: (Element) -> Any) -> [Any] {
    return self.map(encodeJsonElement)
  }
}

extension Dictionary {
  public static func decodeJson(_ decodeKey: (Any) throws -> Key, _ decodeValue: @escaping (Any) throws -> Value) -> (Any) throws -> [Key: Value] {
    return { json in
      guard let dict = json as? [Key: Any] else {
        throw JsonDecodeError.wrongType(rawValue: json, expectedType: "Dictionary")
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
        throw JsonDecodeError.dictionaryErrors(errors)
      }

      return result
    }
  }

  public func encodeJson(_ encodeJsonKey: (Key) -> String, _ encodeJsonValue: (Value) -> Any) -> [String: Any] {
    var dict: [String: Any] = [:]

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
extension Sequence where Iterator.Element == (key: String, value: Any) {
  public static func decodeJson(_ json: Any) throws -> JsonObject {
    guard let result = json as? JsonObject else {
      throw JsonDecodeError.wrongType(rawValue: json, expectedType: "JsonObject")
    }

    return result
  }

  public func encodeJson() -> [String: Any] {
    var dict: [String: Any] = [:]

    for (key, val) in self {
      dict[key] = val
    }

    return dict
  }
}

// JsonArray
extension Sequence where Iterator.Element == Any {
  public static func decodeJson(_ json: Any) throws -> JsonArray {
    guard let result = json as? JsonArray else {
      throw JsonDecodeError.wrongType(rawValue: json, expectedType: "JsonArray")
    }

    return result
  }

  public func encodeJson() -> [Any] {
    return Array(self)
  }
}
