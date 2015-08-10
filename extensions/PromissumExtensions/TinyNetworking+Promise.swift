//
//  TinyNetworking+Promise.swift
//  PromissumExtensions
//
//  Created by Tom Lokhorst on 2015-01-08.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation

public let TinyNetworkingPromiseErrorDomain = "com.nonstrict.promissum.tiny-networking"

public let TinyNetworkingPromiseReasonKey = "reason"
public let TinyNetworkingPromiseDataKey = "data"

public class Box<T> {
  public let unbox: T
  public init(_ value: T) { self.unbox = value }
}

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

  apiRequest(modifyRequest, baseURL: baseURL, resource: resource, failure: onFailure, completion: source.resolve)

  return source.promise
}

extension Reason: CustomStringConvertible {
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
