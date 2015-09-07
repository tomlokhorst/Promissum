//
//  Alamofire+Promise.swift
//  PromissumExtensions
//
//  Created by Tom Lokhorst on 2014-10-12.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation
import Alamofire


public enum AlamofirePromiseError : ErrorType {
  case JsonDecodeError
  case HttpNotFound(result: Alamofire.Result<AnyObject>)
  case HttpError(status: Int, result: Alamofire.Result<AnyObject>?)
  case UnknownError(error: ErrorType, data: NSData?)
}

extension Request {

  public func responseDecodePromise<T>(decoder: AnyObject -> T?) -> Promise<T, AlamofirePromiseError> {

    return self.responseJSONPromise()
      .flatMap { json in
        if let value = decoder(json) {
          return Promise(value: value)
        }
        else {
          return Promise(error: AlamofirePromiseError.JsonDecodeError)
        }
      }
  }

  public func responseJSONPromise() -> Promise<AnyObject, AlamofirePromiseError> {
    let source = PromiseSource<AnyObject, AlamofirePromiseError>()

    self.responseJSON { (request, response, result) -> Void in
      if let resp = response {
        if resp.statusCode == 404 {
          source.reject(AlamofirePromiseError.HttpNotFound(result: result))
          return
        }

        if resp.statusCode < 200 || resp.statusCode > 299 {
          source.reject(AlamofirePromiseError.HttpError(status: resp.statusCode, result: result))
          return
        }
      }

      switch result {
      case let .Success(value):
        source.resolve(value)

      case let .Failure(data, error):
        source.reject(AlamofirePromiseError.UnknownError(error: error, data: data))
      }
    }

    return source.promise
  }
}
