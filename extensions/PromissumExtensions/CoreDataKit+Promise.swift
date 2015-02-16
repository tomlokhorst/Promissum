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
  func toPromise() -> Promise<T> {
    switch self {
    case let .Success(boxedObject):
      return Promise<T>(value: boxedObject())

    case let .Failure(error):
      return Promise<T>(error: error)
    }
  }
}

extension CoreDataKit {
  public class func performBlockOnBackgroundContextPromise(block: PerformBlock) -> Promise<CommitAction> {
    return sharedStack!.performBlockOnBackgroundContextPromise(block)
  }
}

extension CoreDataStack {
  public func performBlockOnBackgroundContextPromise(block: PerformBlock) -> Promise<CommitAction> {
    return backgroundContext.performBlockPromise(block)
  }
}

extension NSManagedObjectContext {
  public func performBlockPromise(block: PerformBlock) -> Promise<CommitAction> {
    let promiseSource = PromiseSource<CommitAction>()

    performBlock(block) { result in
      dispatch_async(dispatch_get_main_queue()) {
        switch result {
        case let .Success(commitAction):
          promiseSource.resolve(commitAction())

        case let .Failure(error):
          promiseSource.reject(error)
        }
      }
    }

    return promiseSource.promise
  }
}
