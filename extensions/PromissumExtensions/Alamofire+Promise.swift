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
public struct ErrorResponse : Error {
  public var request: URLRequest?
  public var response: HTTPURLResponse?
  public var data: Data?
  public var result: Error

  public init(request: URLRequest?, response: HTTPURLResponse?, data: Data?, result: Error) {
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

    self.response(queue: queue) { response in
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

    self.response(queue: queue, responseSerializer: responseSerializer) { response in
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

// MARK: - Decode

extension DataRequest {

  public static func decodeResponseSerializer<T: Decodable>(_ type: T.Type) -> DataResponseSerializer<T>
  {
    let dataSerializer = DataRequest.dataResponseSerializer().serializeResponse

    return DataResponseSerializer { request, response, data, error in
      let result = dataSerializer(request, response, data, error)

      switch result {
      case .success(let data):
        do {
          let decoder = JSONDecoder()
          let value = try decoder.decode(type, from: data)
          return .success(value)
        }
        catch {
          return .failure(error)
        }
      case .failure(let error):
        return .failure(error)
      }
    }
  }

  public func responseDecode<T: Decodable>(_ type: T.Type, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self
  {
    return response(
      responseSerializer: DataRequest.decodeResponseSerializer(type),
      completionHandler: completionHandler
    )
  }

}

extension DataRequest {
  public func responseDecodePromise<T: Decodable>(_ type: T.Type) -> Promise<SuccessResponse<T>, ErrorResponse>
  {
    return self.responsePromise(responseSerializer: DataRequest.decodeResponseSerializer(type))
  }
}


// MARK: - Data

extension DataRequest {
  public func responseDataPromise()
    -> Promise<SuccessResponse<Data>, ErrorResponse>
  {
    return self.responsePromise(responseSerializer: DataRequest.dataResponseSerializer())
  }
}

// MARK: - String

extension DataRequest {
  public func responseStringPromise(
    encoding: String.Encoding? = nil)
    -> Promise<SuccessResponse<String>, ErrorResponse>
  {
    return self.responsePromise(responseSerializer: DataRequest.stringResponseSerializer(encoding: encoding))
  }
}

// MARK: - JSON

extension DataRequest {
  public func responseJSONPromise(
    options: JSONSerialization.ReadingOptions = .allowFragments)
    -> Promise<SuccessResponse<Any>, ErrorResponse>
  {
    return self.responsePromise(responseSerializer: DataRequest.jsonResponseSerializer(options: options))
  }
}

// MARK: - Property List

extension DataRequest {
  public func responsePropertyListPromise(
    options: PropertyListSerialization.ReadOptions = [])
    -> Promise<SuccessResponse<Any>, ErrorResponse>
  {
    return self.responsePromise(responseSerializer: DataRequest.propertyListResponseSerializer(options: options))
  }
}
