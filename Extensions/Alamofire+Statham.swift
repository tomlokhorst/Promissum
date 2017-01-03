//
//  Alamofire+Statham.swift
//  Statham
//
//  Created by Tom Lokhorst on 2015-11-04.
//  Copyright © 2015 nonstrict. All rights reserved.
//

import Foundation

import Alamofire

extension DataRequest {

  public static func jsonDecodeResponseSerializer<T>(decoder: @escaping (Any) throws -> T) -> DataResponseSerializer<T>
  {
    let jsonSerializer = DataRequest.jsonResponseSerializer().serializeResponse

    return DataResponseSerializer { request, response, data, error in
      let jsonResult = jsonSerializer(request, response, data, error)

      switch jsonResult {
      case .success(let object):
        do {
          let value = try decoder(object)
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

  public func responseJsonDecode<T>(
    decoder: @escaping (Any) throws -> T,
    completionHandler: @escaping (DataResponse<T>) -> Void)
    -> Self
  {
    return response(
      responseSerializer: DataRequest.jsonDecodeResponseSerializer(decoder: decoder),
      completionHandler: completionHandler
    )
  }

}
