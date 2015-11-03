//
//  Alamofire+Promise.swift
//  PromissumExtensions
//
//  Created by Tom Lokhorst on 2014-10-12.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation
import Alamofire

/// Used to store all response data returned from a successfully completed `Request`.
/// Based on `Alamofire.Response`.
public struct SuccessResponse<Value> {
  public let request: NSURLRequest?
  public let response: NSHTTPURLResponse?
  public let data: NSData?
  public let result: Value

  public init(request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, result: Value) {
    self.request = request
    self.response = response
    self.data = data
    self.result = result
  }
}


/// Used to store all response data returned from a failed completed `Request`.
/// Based on `Alamofire.Response`.
public struct ErrorResponse<Error: ErrorType> : ErrorType {
  public let request: NSURLRequest?
  public let response: NSHTTPURLResponse?
  public let data: NSData?
  public let result: Error

  public init(request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, result: Error) {
    self.request = request
    self.response = response
    self.data = data
    self.result = result
  }
}

extension Request {

  public func responsePromise(
    queue queue: dispatch_queue_t? = nil)
    -> Promise<SuccessResponse<NSData?>, ErrorResponse<NSError>>
  {
    let source = PromiseSource<SuccessResponse<NSData?>, ErrorResponse<NSError>>()

    self.response(queue: queue) { (request, response, data, error) in
      if let error = error {
        source.reject(ErrorResponse(request: request, response: response, data: data, result: error))
      }
      else {
        source.resolve(SuccessResponse(request: request, response: response, data: data, result: data))
      }
    }

    return source.promise
  }

  public func responsePromise<T: ResponseSerializerType>(
    queue queue: dispatch_queue_t? = nil,
    responseSerializer: T)
    -> Promise<SuccessResponse<T.SerializedObject>, ErrorResponse<T.ErrorObject>>
  {
    let source = PromiseSource<SuccessResponse<T.SerializedObject>, ErrorResponse<T.ErrorObject>>()

    self.response(queue: queue, responseSerializer: responseSerializer) { response in
      switch response.result {
      case .Success(let value):
        source.resolve(SuccessResponse(request: response.request, response: response.response, data: response.data, result: value))
      case .Failure(let error):
        source.reject(ErrorResponse(request: response.request, response: response.response, data: response.data, result: error))
      }
    }

    return source.promise
  }
}

// MARK: - Data

extension Request {
  public func responseDataPromise()
    -> Promise<SuccessResponse<NSData>, ErrorResponse<NSError>>
  {
    return self.responsePromise(responseSerializer: Request.dataResponseSerializer())
  }
}

// MARK: - String

extension Request {
  public func responseStringPromise(
    encoding encoding: NSStringEncoding? = nil)
    -> Promise<SuccessResponse<String>, ErrorResponse<NSError>>
  {
    return self.responsePromise(responseSerializer: Request.stringResponseSerializer(encoding: encoding))
  }
}

// MARK: - JSON

extension Request {
  public func responseJSONPromise(
    options options: NSJSONReadingOptions = .AllowFragments)
    -> Promise<SuccessResponse<AnyObject>, ErrorResponse<NSError>>
  {
    return self.responsePromise(responseSerializer: Request.JSONResponseSerializer(options: options))
  }
}

// MARK: - Property List

extension Request {
  public func responsePropertyListPromise(
    options options: NSPropertyListReadOptions = NSPropertyListReadOptions())
    -> Promise<SuccessResponse<AnyObject>, ErrorResponse<NSError>>
  {
    return self.responsePromise(responseSerializer: Request.propertyListResponseSerializer(options: options))
  }
}
