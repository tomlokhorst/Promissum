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

/// Used to store all response data returned from a successfully completed `Request`.
/// Based on `Alamofire.Response`.
public struct SuccessResponse<Value> {
  public var request: URLRequest?
  public var response: HTTPURLResponse?
  public var data: Data?
  public var result: Value

  public init(request: URLRequest?, response: HTTPURLResponse?, data: Data?, result: Value) {
    self.request = request
    self.response = response
    self.data = data
    self.result = result
  }
}


/// Used to store all response data returned from a failed completed `Request`.
/// Based on `Alamofire.Response`.
public struct ErrorResponse: Error {
  public var request: URLRequest?
  public var response: HTTPURLResponse?
  public var data: Data?
  public var result: AFError

  public init(request: URLRequest?, response: HTTPURLResponse?, data: Data?, result: AFError) {
    self.request = request
    self.response = response
    self.data = data
    self.result = result
  }
}

extension DataRequest {

  public func responsePromise(queue: DispatchQueue? = nil)
    -> Promise<SuccessResponse<Data?>, ErrorResponse>
  {
    let source = PromiseSource<SuccessResponse<Data?>, ErrorResponse>()

    self.response(queue: queue ?? .main) { response in
      if let error = response.error {
        source.reject(ErrorResponse(
          request: response.request,
          response: response.response,
          data: response.data,
          result: error))
      }
      else {
        source.resolve(SuccessResponse(
          request: response.request,
          response: response.response,
          data: response.data,
          result: response.data))
      }
    }

    return source.promise
  }

  public func responsePromise<T: DataResponseSerializerProtocol>(
    queue: DispatchQueue? = nil,
    responseSerializer: T)
    -> Promise<SuccessResponse<T.SerializedObject>, ErrorResponse>
  {
    let source = PromiseSource<SuccessResponse<T.SerializedObject>, ErrorResponse>()

    self.response(queue: queue ?? .main, responseSerializer: responseSerializer) { response in
      switch response.result {
      case .success(let value):
        source.resolve(SuccessResponse(
          request: response.request,
          response: response.response,
          data: response.data,
          result: value))

      case .failure(let error):
        source.reject(ErrorResponse(
          request: response.request,
          response: response.response,
          data: response.data,
          result: error))
      }
    }

    return source.promise
  }
}

// MARK: - Decodable

extension DataRequest {

  public func responseDecodablePromise<T: Decodable>(of type: T.Type, decoder: JSONDecoder = JSONDecoder()) -> Promise<SuccessResponse<T>, ErrorResponse>
  {
    let source = PromiseSource<SuccessResponse<T>, ErrorResponse>()
    self.responseDecodable(of: type, decoder: decoder) { response in
      switch response.result {
      case .success(let value):
        source.resolve(SuccessResponse(
          request: response.request,
          response: response.response,
          data: response.data,
          result: value))

      case .failure(let error):
        source.reject(ErrorResponse(
          request: response.request,
          response: response.response,
          data: response.data,
          result: error))
      }
    }

    return source.promise
  }
}

// MARK: - Data

extension DataRequest {
  public func responseDataPromise()
    -> Promise<SuccessResponse<Data>, ErrorResponse>
  {
    let source = PromiseSource<SuccessResponse<Data>, ErrorResponse>()
    self.responseData { response in
      switch response.result {
      case .success(let value):
        source.resolve(SuccessResponse(
          request: response.request,
          response: response.response,
          data: response.data,
          result: value))

      case .failure(let error):
        source.reject(ErrorResponse(
          request: response.request,
          response: response.response,
          data: response.data,
          result: error))
      }
    }

    return source.promise
  }
}

// MARK: - String

extension DataRequest {
  public func responseStringPromise(
    encoding: String.Encoding? = nil)
    -> Promise<SuccessResponse<String>, ErrorResponse>
  {
    let source = PromiseSource<SuccessResponse<String>, ErrorResponse>()
    self.responseString(encoding: encoding) { response in
      switch response.result {
      case .success(let value):
        source.resolve(SuccessResponse(
          request: response.request,
          response: response.response,
          data: response.data,
          result: value))

      case .failure(let error):
        source.reject(ErrorResponse(
          request: response.request,
          response: response.response,
          data: response.data,
          result: error))
      }
    }

    return source.promise
  }
}

// MARK: - JSON

extension DataRequest {
  public func responseJSONPromise(
    options: JSONSerialization.ReadingOptions = .allowFragments)
    -> Promise<SuccessResponse<Any>, ErrorResponse>
  {
    let source = PromiseSource<SuccessResponse<Any>, ErrorResponse>()
    self.responseJSON(options: options) { response in
      switch response.result {
      case .success(let value):
        source.resolve(SuccessResponse(
          request: response.request,
          response: response.response,
          data: response.data,
          result: value))

      case .failure(let error):
        source.reject(ErrorResponse(
          request: response.request,
          response: response.response,
          data: response.data,
          result: error))
      }
    }

    return source.promise
  }
}
