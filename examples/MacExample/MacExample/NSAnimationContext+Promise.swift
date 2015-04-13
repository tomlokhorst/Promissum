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

  public class func runAnimationGroupPromise(changes: (NSAnimationContext!) -> Void) -> Promise<Void> {
    let source = PromiseSource<Void>()

    self.runAnimationGroup(changes, completionHandler: source.resolve)

    return source.promise
  }
}
