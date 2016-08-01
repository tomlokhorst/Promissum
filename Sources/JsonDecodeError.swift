//
//  JsonDecodeError.swift
//  Statham
//
//  Created by Tom Lokhorst on 2016-02-20.
//  Copyright © 2016 nonstrict. All rights reserved.
//

import Foundation

public enum JsonDecodeError : ErrorProtocol {
  case missingField
  case wrongType(rawValue: AnyObject, expectedType: String)
  case wrongEnumRawValue(rawValue: AnyObject, enumType: String)
  case arrayElementErrors([(Int, JsonDecodeError)])
  case dictionaryErrors([(String, JsonDecodeError)])
  case structErrors(type: String, errors: [(String, JsonDecodeError)])
}

extension JsonDecodeError: CustomStringConvertible {

  public var description: String {
    return multiline(verbosity: .multiple).joined(separator: "\n")
  }

  public var fullDescription: String {
    return multiline(verbosity: .full).joined(separator: "\n")
  }

  private enum Verbosity {
    case full
    case multiple
    case single

    func to(_ other: Verbosity) -> Verbosity {
      if case .full = self { return .full }
      return other
    }
  }

  private func multiline(verbosity: Verbosity) -> [String] {
    switch self {
    case .missingField, .wrongType, .wrongEnumRawValue:
      return [self.line]

    case .arrayElementErrors(let errors):
      let errs = errors.map { (ix, err) in ("[\(ix)]", err) }
      return JsonDecodeError.lines(verbosity: verbosity, type: "array", errors: errs)

    case .dictionaryErrors(let errors):
      let errs = errors.map { (key, err) in ("\(key):", err) }
      return JsonDecodeError.lines(verbosity: verbosity, type: "dictionary", errors: errs)

    case .structErrors(let type, let errors):
      let errs = errors.map { (key, err) in ("\(key):", err) }
      return JsonDecodeError.lines(verbosity: verbosity, type: "\(type) struct", errors: errs)
    }
  }

  private var line: String {
    switch self {
    case .missingField:
      return "Field missing"

    case let .wrongType(rawValue, expectedType):
      return "Value is not of expected type \(expectedType): `\(rawValue)`"

    case let .wrongEnumRawValue(rawValue, enumType):
      return "`\(rawValue)` is not a valid case in enum \(enumType)"

    case let .arrayElementErrors(errors):
      return errors.count == 1
        ? "(1 error in an array element)"
        : "(\(errors.count) errors in array elements)"

    case let .dictionaryErrors(errors):
      return errors.count == 1
        ? "(1 error in dictionary)"
        : "(\(errors.count) errors in dictionary)"

    case let .structErrors(type, errors):
      return errors.count == 1
        ? "(1 error in nested \(type) struct)"
        : "(\(errors.count) errors in nested \(type) struct)"
    }
  }

  private func listItem(collapsed: Bool) -> String {
    switch self {
    case .missingField, .wrongType, .wrongEnumRawValue:
      return "-"

    case .arrayElementErrors, .dictionaryErrors, .structErrors:
      return collapsed ? "▹" : "▿"
    }
  }

  private static func lines(verbosity: Verbosity, type: String, errors: [(String, JsonDecodeError)]) -> [String] {
    if errors.count == 0 { return [] }

    func prefix(_ prefix: String, lines: [String]) -> [String] {
      if let first = lines.first {
        let fst = ["\(prefix)\(first)"]
        let rst = lines.suffix(from: 1).map { "   \($0)" }
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
      if multiple && verbosity == .single {
        result.append(" \(error.listItem(collapsed: true)) \(key) \(error.line)")
      }
      else {
        let lines = error.multiline(verbosity: verbosity.to(.single))
        result = result + prefix(" \(error.listItem(collapsed: false)) \(key) ", lines: lines)
      }
    }
    
    return result
  }
}
