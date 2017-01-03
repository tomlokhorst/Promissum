//
//  Alamofire+Promissum+Statham.swift
//  Statham
//
//  Created by Tom Lokhorst on 2015-11-04.
//  Copyright © 2015 nonstrict. All rights reserved.
//

import Alamofire
import Promissum

extension DataRequest {
  public func responseJsonDecodePromise<T>(
    decoder: @escaping (Any) throws -> T)
    -> Promise<SuccessResponse<T>, ErrorResponse>
  {
    return self.responsePromise(responseSerializer: DataRequest.jsonDecodeResponseSerializer(decoder: decoder))
  }
}
