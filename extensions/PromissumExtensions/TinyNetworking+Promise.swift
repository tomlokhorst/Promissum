//
//  TinyNetworking+Promise.swift
//  PromissumExtensions
//
//  Created by Tom Lokhorst on 2015-01-08.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation
import Promissum

public typealias TinyNetworkingError = (reason: Reason, data: NSData?)

public func apiRequestPromise<A>(modifyRequest: NSMutableURLRequest -> (), baseURL: NSURL, resource: Resource<A>) -> Promise<A, TinyNetworkingError> {
  let source = PromiseSource<A, TinyNetworkingError>()

  apiRequest(modifyRequest, baseURL, resource, source.reject, source.resolve)

  return source.promise
}

extension Reason: Printable {
  public var description: String {
    switch self {
    case .CouldNotParseJSON:
      return "CouldNotParseJSON"
    case .NoData:
      return "NoData"
    case .NoSuccessStatusCode(let statusCode):
      return "NoSuccessStatusCode(\(statusCode))"
    case .Other(let error):
      return "Other(\(error))"
    }
  }
}
