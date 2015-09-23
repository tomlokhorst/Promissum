//
//  Alamofire+Promise.swift
//  PromissumExtensions
//
//  Created by Tom Lokhorst on 2014-10-12.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation
import Alamofire


public struct AFPValue<T> {
  public let request: NSURLRequest?
  public let response: NSHTTPURLResponse?
  public let value: T
}

public struct AFPError {
  public let request: NSURLRequest?
  public let response: NSHTTPURLResponse?
  public let data: NSData?
  public let error: ErrorType
}

extension Request {

  public func responsePromise<T: ResponseSerializer, V where T.SerializedObject == V>(
    queue queue: dispatch_queue_t? = nil, responseSerializer: T) -> Promise<AFPValue<V>, AFPError> {

    let source = PromiseSource<AFPValue<V>, AFPError>()

    self.response(queue: queue, responseSerializer: responseSerializer) { request, response, result in
      switch result {
      case let .Failure(data, error):
        source.reject(AFPError(request: request, response: response, data: data, error: error))
      case let.Success(value):
        source.resolve(AFPValue(request: request, response: response, value: value))
      }
    }

    return source.promise
  }
}

// MARK: - JSON decode

public enum AlamofireDecodeError : ErrorType {
  case JsonDecodeError
  case HttpError(status: Int, result: Alamofire.Result<AnyObject>?)
  case UnknownError(error: ErrorType, data: NSData?)
}

extension Request {
  public func responseDecodePromise<T>(decoder: AnyObject -> T?) -> Promise<T, AlamofireDecodeError> {

    return self.responseJSONPromise()
      .mapError { err in
        if let resp = err.response where resp.statusCode < 200 || resp.statusCode > 299 {
          let result: Alamofire.Result<AnyObject> = Alamofire.Result.Failure(err.data, err.error)
          return AlamofireDecodeError.HttpError(status: resp.statusCode, result: result)
        }

        return AlamofireDecodeError.UnknownError(error: err.error, data: err.data)
      }
      .flatMap { val in
        // Don't know if this will ever happen, but better safe than sorry.
        if let resp = val.response where resp.statusCode < 200 || resp.statusCode > 299 {
          let result = Alamofire.Result.Success(val.value)
          return Promise(error: AlamofireDecodeError.HttpError(status: resp.statusCode, result: result))
        }

        guard let decoded = decoder(val.value) else {
          return Promise(error: AlamofireDecodeError.JsonDecodeError)
        }

        return Promise(value: decoded)
      }
  }
}

// MARK: - Data

extension Request {
  public func responseDataPromise() -> Promise<AFPValue<NSData>, AFPError> {
    return self.responsePromise(responseSerializer: Request.dataResponseSerializer())
  }
}

// MARK: - String

extension Request {
  public func responseStringPromise(encoding encoding: NSStringEncoding? = nil) -> Promise<AFPValue<String>, AFPError> {
    return self.responsePromise(responseSerializer: Request.stringResponseSerializer(encoding: encoding))
  }
}

// MARK: - JSON

extension Request {
  public func responseJSONPromise(options options: NSJSONReadingOptions = .AllowFragments) -> Promise<AFPValue<AnyObject>, AFPError> {
    return self.responsePromise(responseSerializer: Request.JSONResponseSerializer(options: options))
  }
}

// MARK: - Property List

extension Request {
  public func responsePropertyListPromise(options options: NSPropertyListReadOptions = NSPropertyListReadOptions()) -> Promise<AFPValue<AnyObject>, AFPError> {
    return self.responsePromise(responseSerializer: Request.propertyListResponseSerializer(options: options))
  }
}
