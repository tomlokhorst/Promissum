//
//  CoreDataKit+Promise.swift
//  PromissumExtensions
//
//  Created by Mathijs Kadijk on 2014-10-27.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData
import CoreDataKit
import enum CoreDataKit.Result
import Promissum

extension Result {
  func toPromise() -> Promise<T, NSError> {
    switch self {
    case let .Success(boxed):
      return Promise(value: boxed.value)

    case let .Failure(error):
      return Promise(error: error)
    }
  }
}

extension CDK {
  public class func performBlockOnBackgroundContextPromise(block: PerformBlock) -> Promise<CommitAction, NSError> {
    return sharedStack!.performBlockOnBackgroundContextPromise(block)
  }
}

extension CoreDataStack {
  public func performBlockOnBackgroundContextPromise(block: PerformBlock) -> Promise<CommitAction, NSError> {
    return rootContext.performBlockPromise(block)
  }
}

extension NSManagedObjectContext {
  public func performBlockPromise(block: PerformBlock) -> Promise<CommitAction, NSError> {
    let promiseSource = PromiseSource<CommitAction, NSError>()

    performBlock(block) { result in
      dispatch_async(dispatch_get_main_queue()) {
        switch result {
        case let .Success(boxed):
          promiseSource.resolve(boxed.value)

        case let .Failure(error):
          promiseSource.reject(error)
        }
      }
    }

    return promiseSource.promise
  }
}
