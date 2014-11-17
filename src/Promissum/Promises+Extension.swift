//
//  Promises+Extension.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

extension Promise {

  // A bunch of convenience synonyms

  public func then<U>(continuation: T -> U) -> Promise<U> {
    return self.map(continuation)
  }

  public func then<U>(continuation: T -> Promise<U>) -> Promise<U> {
    return self.flatMap(continuation)
  }

  public func catch(continuation: NSError -> T) -> Promise<T> {
    return self.mapError(continuation)
  }

  public func catch<U>(continuation: NSError -> Promise<T>) -> Promise<T> {
    return self.flatMapError(continuation)
  }
}
