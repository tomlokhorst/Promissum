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
import Promissum


extension CDK {
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
        do {
          let action = try result()
          promiseSource.resolve(action)
        }
        catch let error as NSError {
          promiseSource.reject(error)
        }
        catch {
          fatalError("Should never happen")
        }
      }
    }

    return promiseSource.promise
  }
}
