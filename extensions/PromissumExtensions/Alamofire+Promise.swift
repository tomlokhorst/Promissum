//
//  Alamofire+Promise.swift
//  PromissumExtensions
//
//  Created by Tom Lokhorst on 2014-10-12.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation
import Alamofire
import Promissum

public let AlamofirePromiseErrorDomain = "com.nonstrict.promissum.alamofire"

public let AlamofirePromiseRequestKey = "request"
public let AlamofirePromiseResponseKey = "response"
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

    self.responseJSON { (request, response, data, error) in

      if let resp = response {
        if resp.statusCode == 404 {
          source.reject(self.makeError(.HttpNotFound, description: "HTTP 404 Not Found", request: request, response: response, data: data, error: error))
          return
        }

        if resp.statusCode != 200 {
          source.reject(self.makeError(.HttpError, description: "HTTP statusCode: \(resp.statusCode)", request: request, response: response, data: data, error: error))
          return
        }
      }

      if let err = error {
        source.reject(err)
        return
      }

      if response == nil {
        source.reject(self.makeError(.NoResponseAvailable, description: "No response available", request: request, response: response, data: data, error: error))
        return
      }

      if let json : AnyObject = data {
        source.resolve(json)
        return
      }

      let error = self.makeError(.UnknownError, description: "Unknown error", request: request, response: response, data: data, error: error)
      source.reject(error)
    }

    return source.promise
  }

  private func makeError(code: AlamofirePromiseErrorCode, description: String, request: NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> NSError {

    var userInfo: [NSObject: AnyObject] = [
      NSLocalizedDescriptionKey: description,
      AlamofirePromiseRequestKey: request
    ]

    if response != nil {
      userInfo[AlamofirePromiseResponseKey] = response!
    }
    if data != nil {
      userInfo[AlamofirePromiseDataKey] = data!
    }
    if error != nil {
      userInfo[AlamofirePromiseErrorKey] = error
    }

    return NSError(domain: AlamofirePromiseErrorDomain, code: code.rawValue, userInfo: userInfo)
  }
}
