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


public enum AlamofirePromiseError {
  case NoResponseAvailable
  case NoDataAvailable
  case JsonDecodeError
  case HttpNotFound(data: AnyObject?)
  case HttpError(status: Int, data: AnyObject?)
  case UnknownError(error: NSError)
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

    self.responseJSON { (request, response, data, error) in

      if let resp = response {
        if resp.statusCode == 404 {
          source.reject(AlamofirePromiseError.HttpNotFound(data: data))
          return
        }

        if resp.statusCode < 200 || resp.statusCode > 299 {
          source.reject(AlamofirePromiseError.HttpError(status: resp.statusCode, data: data))
          return
        }
      }

      if let err = error {
        source.reject(AlamofirePromiseError.UnknownError(error: err))
        return
      }

      if response == nil {
        source.reject(AlamofirePromiseError.NoResponseAvailable)
        return
      }

      if let json : AnyObject = data {
        source.resolve(json)
        return
      }

      source.reject(AlamofirePromiseError.NoDataAvailable)
    }

    return source.promise
  }
}
