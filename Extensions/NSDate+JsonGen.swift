//
//  Foundation+JsonGen.swift
//  Statham
//
//  Created by Tom Lokhorst on 2016-02-20.
//  Copyright © 2016 nonstrict. All rights reserved.
//

import Foundation

extension NSDate
{
  private struct JsonGenDateFormatter {
    static let withTimeZone : NSDateFormatter = {
      let formatter = NSDateFormatter()
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
      formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")

      return formatter
    }()
  }

  public static func decodeJson(json : AnyObject) throws -> NSDate {
    guard let str = json as? String,
      let result = JsonGenDateFormatter.withTimeZone.dateFromString(str)
      else {
        throw JsonDecodeError.WrongType(rawValue: json, expectedType: "ISO 8601 formatted NSDate")
    }

    return result
  }

  public func encodeJson() -> String {
    return JsonGenDateFormatter.withTimeZone.stringFromDate(self)
  }
}
