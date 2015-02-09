//
//  UIKit+Promise.swift
//  PromissumExtensions
//
//  Created by Tom Lokhorst on 2015-01-12.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Promissum
import UIKit

extension UIView {
  public class func animatePromise(# duration: NSTimeInterval, animations: () -> Void) -> Promise<Bool> {
    let source = PromiseSource<Bool>()

    self.animateWithDuration(duration, animations: animations, completion: source.resolve)

    return source.promise
  }

  public class func animatePromise(# duration: NSTimeInterval, delay: NSTimeInterval, options: UIViewAnimationOptions, animations: () -> Void) -> Promise<Bool> {
    let source = PromiseSource<Bool>()

    self.animateWithDuration(duration, delay: delay, options: options, animations: animations, completion: source.resolve)

    return source.promise
  }

  public class func transitionWithViewPromise(view: UIView, duration: NSTimeInterval, options: UIViewAnimationOptions, animations: () -> Void) -> Promise<Bool> {
    let source = PromiseSource<Bool>()

    self.transitionWithView(view, duration: duration, options: options, animations: animations, completion: source.resolve)

    return source.promise
  }

  public class func transitionFromViewPromise(fromView: UIView, toView: UIView, duration: NSTimeInterval, options: UIViewAnimationOptions) -> Promise<Bool> {
    let source = PromiseSource<Bool>()

    self.transitionFromView(fromView, toView: toView, duration: duration, options: options, completion: source.resolve)

    return source.promise
  }

  public class func performSystemAnimationPromise(animation: UISystemAnimation, onViews views: [AnyObject], options: UIViewAnimationOptions, animations parallelAnimations: (() -> Void)?) -> Promise<Bool> {
    let source = PromiseSource<Bool>()

    self.performSystemAnimation(animation, onViews: views, options: options, animations: parallelAnimations, completion: source.resolve)

    return source.promise
  }

  public class func animateKeyframesPromise(duration: NSTimeInterval, delay: NSTimeInterval, options: UIViewKeyframeAnimationOptions, animations: () -> Void) -> Promise<Bool> {
    let source = PromiseSource<Bool>()

    self.animateKeyframesWithDuration(duration, delay: delay, options: options, animations: animations, completion: source.resolve)

    return source.promise
  }
}

extension UIViewController {
  public func presentViewControllerPromise(viewControllerToPresent: UIViewController, animated flag: Bool) -> Promise<Void> {
    let source = PromiseSource<Void>()

    self.presentViewController(viewControllerToPresent, animated: flag, completion: source.resolve)

    return source.promise
  }

  public func dismissViewControllerPromise(animated flag: Bool) -> Promise<Void> {
    let source = PromiseSource<Void>()

    self.dismissViewControllerAnimated(flag, completion: source.resolve)

    return source.promise
  }

  public func transitionFromViewControllerPromise(fromViewController: UIViewController, toViewController: UIViewController, duration: NSTimeInterval, options: UIViewAnimationOptions, animations: (() -> Void)?) -> Promise<Bool> {
    let source = PromiseSource<Bool>()

    self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: duration, options: options, animations: animations, completion: source.resolve)

    return source.promise
  }
}
