//
//  Warning.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2017-04-06.
//  Copyright © 2017 Tom Lokhorst. All rights reserved.
//

import Foundation

public enum Warning {
  case print
  case fatalError
  case callback((Callstack) -> ())
  case dontWarn
}

public struct Callstack : CustomStringConvertible {
  public var locations: [SourceLocation]

  public init() {
    self.locations = []
  }

  public init(source: SourceLocation) {
    self.locations = [source]
  }

  public var isEmpty: Bool {
    return locations.isEmpty
  }

  public var description: String {
    var lines: [String] = []

    for location in locations {
      let name = "\(location.name):".padding(toLength: 18, withPad: " ", startingAt: 0)
      let str = "\(name)\(location.file):\(location.line):\(location.column) - \(location.function)"

      lines.append(str)
    }

    return lines.joined(separator: "\n")
  }

  public func appending(_ location: SourceLocation) -> Callstack {
    var result = self
    result.locations.append(location)
    return result
  }
}

public struct SourceLocation {
  public let file: String
  public let line: Int
  public let column: Int
  public let function: String
  public let name: String

  public init(file: String, line: Int, column: Int, function: String, name: String) {
    self.file = file
    self.line = line
    self.column = column
    self.function = function
    self.name = name
  }
}
//
//private func createCallstack(source: SourceLocation?, originalSource: OriginalSource?) -> [SourceLocation] {
//  guard let sourceLocation = source else { return [] }
//
//  var callstack = [sourceLocation]
//  var parent = originalSource
//
//  while parent != nil {
//    if let location = parent?.sourceLocation {
//      callstack.append(location)
//    }
//
//    parent = originalSource?.originalSource
//  }
//
//  return callstack.reversed()
//}
