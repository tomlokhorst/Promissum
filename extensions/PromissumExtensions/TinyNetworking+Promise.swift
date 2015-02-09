//
//  TinyNetworking+Promise.swift
//  PromissumExtensions
//
//  Created by Tom Lokhorst on 2015-01-08.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation
import Promissum

public let TinyNetworkingPromiseErrorDomain = "com.nonstrict.promissum.tiny-networking"

public let TinyNetworkingPromiseReasonKey = "reason"
public let TinyNetworkingPromiseDataKey = "data"

public func apiRequestPromise<A>(modifyRequest: NSMutableURLRequest -> (), baseURL: NSURL, resource: Resource<A>) -> Promise<A> {
  let source = PromiseSource<A>()

  func onFailure(reason: Reason, data: NSData?) {
    var userInfo: [NSObject: AnyObject] = [
      TinyNetworkingPromiseReasonKey: Box(reason),
    ]
    if let data = data {
      userInfo[TinyNetworkingPromiseDataKey] = data
    }

    source.reject(NSError(domain: TinyNetworkingPromiseErrorDomain, code: -1, userInfo: userInfo))
  }

  apiRequest(modifyRequest, baseURL, resource, onFailure, source.resolve)

  return source.promise
}

extension Reason: Printable {
  public var description: String {
    switch self {
    case .CouldNotParseJSON:
      return "CouldNotParseJSON"
    case .NoData:
      return "NoData"
    case let .NoSuccessStatusCode(x):
      return "NoSuccessStatusCode(\(x.statusCode))"
    case let .Other(error):
      return "Other(\(error))"
    }
  }
}
