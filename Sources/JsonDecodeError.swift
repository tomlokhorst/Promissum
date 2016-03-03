//
//  JsonDecodeError.swift
//  Statham
//
//  Created by Tom Lokhorst on 2016-02-20.
//  Copyright © 2016 nonstrict. All rights reserved.
//

import Foundation

public enum JsonDecodeError : ErrorType {
  case MissingField
  case WrongType(rawValue: AnyObject, expectedType: String)
  case WrongEnumRawValue(rawValue: AnyObject, enumType: String)
  case ArrayElementErrors([(Int, JsonDecodeError)])
  case DictionaryErrors([(String, JsonDecodeError)])
  case StructErrors(type: String, errors: [(String, JsonDecodeError)])
}

extension JsonDecodeError: CustomStringConvertible {

  public var description: String {
    return multiline(Verbosity.Multiple).joinWithSeparator("\n")
  }

  public var fullDescription: String {
    return multiline(Verbosity.Full).joinWithSeparator("\n")
  }

  private enum Verbosity {
    case Full
    case Multiple
    case Single

    func to(other: Verbosity) -> Verbosity {
      if case .Full = self { return .Full }
      return other
    }
  }

  private func multiline(verbosity: Verbosity) -> [String] {
    switch self {
    case .MissingField, .WrongType, .WrongEnumRawValue:
      return [self.line]

    case .ArrayElementErrors(let errors):
      let errs = errors.map { (ix, err) in ("[\(ix)]", err) }
      return JsonDecodeError.lines(verbosity, type: "array", errors: errs)

    case .DictionaryErrors(let errors):
      let errs = errors.map { (key, err) in ("\(key):", err) }
      return JsonDecodeError.lines(verbosity, type: "dictionary", errors: errs)

    case .StructErrors(let type, let errors):
      let errs = errors.map { (key, err) in ("\(key):", err) }
      return JsonDecodeError.lines(verbosity, type: "\(type) struct", errors: errs)
    }
  }

  private var line: String {
    switch self {
    case .MissingField:
      return "Field missing"

    case let .WrongType(rawValue, expectedType):
      return "Value is not of expected type \(expectedType): `\(rawValue)`"

    case let .WrongEnumRawValue(rawValue, enumType):
      return "`\(rawValue)` is not a valid case in enum \(enumType)"

    case let .ArrayElementErrors(errors):
      return errors.count == 1
        ? "(1 error in an array element)"
        : "(\(errors.count) errors in array elements)"

    case let .DictionaryErrors(errors):
      return errors.count == 1
        ? "(1 error in dictionary)"
        : "(\(errors.count) errors in dictionary)"

    case let .StructErrors(type, errors):
      return errors.count == 1
        ? "(1 error in nested \(type) struct)"
        : "(\(errors.count) errors in nested \(type) struct)"
    }
  }

  private func listItem(collapsed collapsed: Bool) -> String {
    switch self {
    case .MissingField, .WrongType, .WrongEnumRawValue:
      return "-"

    case .ArrayElementErrors, .DictionaryErrors, .StructErrors:
      return collapsed ? "▹" : "▿"
    }
  }

  private static func lines(verbosity: Verbosity, type: String, errors: [(String, JsonDecodeError)]) -> [String] {
    if errors.count == 0 { return [] }

    func prefix(prefix: String, lines: [String]) -> [String] {
      if let first = lines.first {
        let fst = ["\(prefix)\(first)"]
        let rst = lines.suffixFrom(1).map { "   \($0)" }
        return fst + rst
      }

      return []
    }

    var result: [String] = []
    let multiple = errors.count > 1

    let head = multiple
      ? "\(errors.count) errors in \(type)"
      : "1 error in \(type)"
    result.append(head)

    for (key, error) in errors {
      if multiple && verbosity == .Single {
        result.append(" \(error.listItem(collapsed: true)) \(key) \(error.line)")
      }
      else {
        let lines = error.multiline(verbosity.to(.Single))
        result = result + prefix(" \(error.listItem(collapsed: false)) \(key) ", lines: lines)
      }
    }
    
    return result
  }
}
