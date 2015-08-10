//
//  Alamofire+Promise.swift
//  PromissumExtensions
//
//  Created by Tom Lokhorst on 2014-10-12.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation
import Alamofire

public let AlamofirePromiseErrorDomain = "com.nonstrict.promissum.alamofire"

public let AlamofirePromiseRequestKey = "request"
public let AlamofirePromiseResponseKey = "response"
public let AlamofirePromiseValueKey = "value"
public let AlamofirePromiseDataKey = "data"
public let AlamofirePromiseErrorKey = "error"

public enum AlamofirePromiseErrorCode : Int {
  case UnknownError = 1
  case HttpNotFound
  case HttpError
  case JsonDecodeError
  case NoResponseAvailable
}

extension Request {

  public func responseDecodePromise<T>(decoder: AnyObject -> T?) -> Promise<T> {

    return self.responseJSONPromise()
      .flatMap { json in
        if let value = decoder(json) {
          return Promise(value: value)
        }
        else {
          let userInfo = [
            NSLocalizedDescriptionKey: "JSON could not be decoded."
          ]
          return Promise(error: NSError(domain: AlamofirePromiseErrorDomain, code: AlamofirePromiseErrorCode.JsonDecodeError.rawValue, userInfo: userInfo))
        }
      }
  }

  public func responseJSONPromise() -> Promise<AnyObject> {
    let source = PromiseSource<AnyObject>()

    self.responseJSON { (request, response, result) -> Void in
      if let resp = response {
        if resp.statusCode == 404 {
          source.reject(self.makeError(.HttpNotFound, description: "HTTP 404 Not Found", request: request, response: response, result: result))
          return
        }

        if resp.statusCode != 200 {
          source.reject(self.makeError(.HttpError, description: "HTTP statusCode: \(resp.statusCode)", request: request, response: response, result: result))
          return
        }
      }

      switch result {
      case let .Success(value):
        source.resolve(value)

      case let .Failure(_, error):
        source.reject(error)
      }
    }

    return source.promise
  }

  private func makeError(code: AlamofirePromiseErrorCode, description: String, request: NSURLRequest?, response: NSHTTPURLResponse?, result: Alamofire.Result<AnyObject>) -> NSError {

    var userInfo: [NSObject: AnyObject] = [
      NSLocalizedDescriptionKey: description
    ]

    if let request = request {
      userInfo[AlamofirePromiseRequestKey] = request
    }

    if let response = response {
      userInfo[AlamofirePromiseResponseKey] = response
    }

    switch result {
    case let .Success(value):
      userInfo[AlamofirePromiseValueKey] = value

    case let .Failure(data, error):
      userInfo[AlamofirePromiseErrorKey] = error

      if let data = data {
        userInfo[AlamofirePromiseDataKey] = data
      }
    }

    return NSError(domain: AlamofirePromiseErrorDomain, code: code.rawValue, userInfo: userInfo)
  }
}
