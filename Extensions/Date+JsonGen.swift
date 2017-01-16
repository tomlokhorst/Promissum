//
//  Date+JsonGen.swift
//  Statham
//
//  Created by Tom Lokhorst on 2016-02-20.
//  Copyright © 2016 nonstrict. All rights reserved.
//

import Foundation

extension Date
{
  private struct JsonGenDateFormatter {
    static let withTimeZone: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
      formatter.locale = Locale(identifier: "en_US_POSIX")

      return formatter
    }()
  }

  public static func decodeJson(_ json: Any) throws -> Date {
    guard
      let str = json as? String,
      let result = JsonGenDateFormatter.withTimeZone.date(from: str)
    else {
      throw JsonDecodeError.wrongType(rawValue: json, expectedType: "ISO 8601 formatted NSDate")
    }

    return result
  }

  public func encodeJson() -> String {
    return JsonGenDateFormatter.withTimeZone.string(from: self)
  }
}
