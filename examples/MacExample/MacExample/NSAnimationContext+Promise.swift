//
//  NSAnimationContext+Promise.swift
//  MacExample
//
//  Created by Tom Lokhorst on 2015-03-01.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Cocoa
import Promissum

extension NSAnimationContext {

  public class func runAnimationGroupPromise(_ changes: (NSAnimationContext!) -> Void) -> Promise<Void, NoError> {
    let source = PromiseSource<Void, NoError>()

    self.runAnimationGroup(changes, completionHandler: source.resolve)

    return source.promise
  }
}
