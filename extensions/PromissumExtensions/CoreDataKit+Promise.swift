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
  public class func performOnBackgroundContextPromise(block: @escaping PerformBlock) -> Promise<CommitAction, CoreDataKitError> {
    return sharedStack!.performOnBackgroundContextPromise(block: block)
  }

  @available(*, unavailable, renamed: "performOnBackgroundContextPromise(block:)")
  public class func performBlockOnBackgroundContextPromise(_ block: PerformBlock) -> Promise<CommitAction, CoreDataKitError> {
    fatalError()
  }
}

extension CoreDataStack {
  public func performOnBackgroundContextPromise(block: @escaping PerformBlock) -> Promise<CommitAction, CoreDataKitError> {
    return backgroundContext.perform(block: block)
  }

  @available(*, unavailable, renamed: "performOnBackgroundContextPromise(block:)")
  public func performBlockOnBackgroundContextPromise(_ block: PerformBlock) -> Promise<CommitAction, CoreDataKitError> {
    fatalError()
  }
}

extension NSManagedObjectContext {
  public func perform(block: @escaping PerformBlock) -> Promise<CommitAction, CoreDataKitError> {
    let promiseSource = PromiseSource<CommitAction, CoreDataKitError>()

    perform(block: block) { result in
      do {
        let action = try result()
        promiseSource.resolve(action)
      }
      catch let error as CoreDataKitError {
          promiseSource.reject(error)
      }
      catch let error {
        promiseSource.reject(CoreDataKitError.unknownError(description: "\(error)"))
      }
    }

    return promiseSource.promise
  }

  @available(*, unavailable, renamed: "perform(block:)")
  public func performBlockPromise(_ block: PerformBlock) -> Promise<CommitAction, CoreDataKitError> {
    fatalError()
  }
}
