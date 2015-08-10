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


extension CDK {
  public class func performBlockOnBackgroundContextPromise(block: PerformBlock) -> Promise<CommitAction, CoreDataKitError> {
    return sharedStack!.performBlockOnBackgroundContextPromise(block)
  }
}

extension CoreDataStack {
  public func performBlockOnBackgroundContextPromise(block: PerformBlock) -> Promise<CommitAction, CoreDataKitError> {
    return backgroundContext.performBlockPromise(block)
  }
}

extension NSManagedObjectContext {
  public func performBlockPromise(block: PerformBlock) -> Promise<CommitAction, CoreDataKitError> {
    let promiseSource = PromiseSource<CommitAction, CoreDataKitError>()

    performBlock(block) { result in
      dispatch_async(dispatch_get_main_queue()) {
        do {
          let action = try result()
          promiseSource.resolve(action)
        }
        catch let error as CoreDataKitError {
            promiseSource.reject(error)
        }
        catch let error {
          promiseSource.reject(CoreDataKitError.UnknownError(description: "\(error)"))
        }
      }
    }

    return promiseSource.promise
  }
}
