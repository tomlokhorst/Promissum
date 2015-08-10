//
//  UIKit+Promise.swift
//  PromissumExtensions
//
//  Created by Tom Lokhorst on 2015-01-12.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import UIKit

extension UIView {
  public class func animatePromise(duration duration: NSTimeInterval, animations: () -> Void) -> Promise<Bool> {
    let source = PromiseSource<Bool>()

    self.animateWithDuration(duration, animations: animations, completion: source.resolve)

    return source.promise
  }

  public class func animatePromise(duration duration: NSTimeInterval, delay: NSTimeInterval, options: UIViewAnimationOptions, animations: () -> Void) -> Promise<Bool> {
    let source = PromiseSource<Bool>()

    self.animateWithDuration(duration, delay: delay, options: options, animations: animations, completion: source.resolve)

    return source.promise
  }

  public class func transitionPromise(view view: UIView, duration: NSTimeInterval, options: UIViewAnimationOptions, animations: () -> Void) -> Promise<Bool> {
    let source = PromiseSource<Bool>()

    self.transitionWithView(view, duration: duration, options: options, animations: animations, completion: source.resolve)

    return source.promise
  }

  public class func transitionPromise(fromView fromView: UIView, toView: UIView, duration: NSTimeInterval, options: UIViewAnimationOptions) -> Promise<Bool> {
    let source = PromiseSource<Bool>()

    self.transitionFromView(fromView, toView: toView, duration: duration, options: options, completion: source.resolve)

    return source.promise
  }

  public class func performSystemAnimationPromise(animation: UISystemAnimation, onViews views: [UIView], options: UIViewAnimationOptions, animations parallelAnimations: (() -> Void)?) -> Promise<Bool> {
    let source = PromiseSource<Bool>()

    self.performSystemAnimation(animation, onViews: views, options: options, animations: parallelAnimations, completion: source.resolve)

    return source.promise
  }

  public class func animateKeyframesPromise(duration duration: NSTimeInterval, delay: NSTimeInterval, options: UIViewKeyframeAnimationOptions, animations: () -> Void) -> Promise<Bool> {
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

  public func transitionPromise(fromViewController fromViewController: UIViewController, toViewController: UIViewController, duration: NSTimeInterval, options: UIViewAnimationOptions, animations: (() -> Void)?) -> Promise<Bool> {
    let source = PromiseSource<Bool>()

    self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: duration, options: options, animations: animations, completion: source.resolve)

    return source.promise
  }
}

var associatedObjectHandle: UInt8 = 0
let associationPolicy = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC

// UIAlertView is deprecated per iOS 8, however this extension is here for convenience
extension UIAlertView {
  var strongDelegate: AlertViewDelegate? {
    get {
      return (objc_getAssociatedObject(self, &associatedObjectHandle) as! AlertViewDelegate)
    }
    set {
      objc_setAssociatedObject(self, &associatedObjectHandle, newValue, associationPolicy)
    }
  }

  public func showPromise() -> Promise<Int> {
    let source = PromiseSource<Int>()
    let originalDelegate = self.delegate as? UIAlertViewDelegate

    self.delegate = AlertViewDelegate(source: source, alertView: self, originalDelegate: originalDelegate)
    self.show()

    return source.promise
  }

  internal class AlertViewDelegate: NSObject, UIAlertViewDelegate {
    let source: PromiseSource<Int>
    let alertView: UIAlertView
    let originalDelegate: UIAlertViewDelegate?

    init(source: PromiseSource<Int>, alertView: UIAlertView, originalDelegate: UIAlertViewDelegate?) {
      self.source = source
      self.alertView = alertView
      self.originalDelegate = originalDelegate

      super.init()

      self.alertView.strongDelegate = self
    }

    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
      originalDelegate?.alertView?(alertView, clickedButtonAtIndex: buttonIndex)

      source.resolve(buttonIndex)

      self.alertView.strongDelegate = nil
    }

    func alertViewCancel(alertView: UIAlertView) {
      originalDelegate?.alertViewCancel?(alertView)
    }

    func willPresentAlertView(alertView: UIAlertView) {
      originalDelegate?.willPresentAlertView?(alertView)
    }

    func didPresentAlertView(alertView: UIAlertView) {
      originalDelegate?.didPresentAlertView?(alertView)
    }

    func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
      originalDelegate?.alertView?(alertView, willDismissWithButtonIndex: buttonIndex)
    }

    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
      originalDelegate?.alertView?(alertView, didDismissWithButtonIndex: buttonIndex)
    }

    func alertViewShouldEnableFirstOtherButton(alertView: UIAlertView) -> Bool {
      return originalDelegate?.alertViewShouldEnableFirstOtherButton?(alertView) ?? false
    }
  }
}

// UIActionSheet is deprecated per iOS 8, however this extension is here for convenience
@available(iOS, deprecated=8.3, message="'UIActionSheet' was deprecated in iOS 8.3: UIActionSheet is deprecated. Use UIAlertController with a preferredStyle of UIAlertControllerStyleActionSheet instead")
extension UIActionSheet {
  var strongDelegate: ActionSheetDelegate? {
    get {
      return (objc_getAssociatedObject(self, &associatedObjectHandle) as! ActionSheetDelegate)
    }
    set {
      objc_setAssociatedObject(self, &associatedObjectHandle, newValue, associationPolicy)
    }
  }

  public func showInViewPromise(view: UIView!) -> Promise<Int> {
    let source = PromiseSource<Int>()
    let originalDelegate = self.delegate

    self.delegate = ActionSheetDelegate(source: source, actionSheet: self, originalDelegate: originalDelegate)
    self.showInView(view)

    return source.promise
  }

  internal class ActionSheetDelegate: NSObject, UIActionSheetDelegate {
    let source: PromiseSource<Int>
    let actionSheet: UIActionSheet
    let originalDelegate: UIActionSheetDelegate?

    init(source: PromiseSource<Int>, actionSheet: UIActionSheet, originalDelegate: UIActionSheetDelegate?) {
      self.source = source
      self.actionSheet = actionSheet
      self.originalDelegate = originalDelegate

      super.init()

      self.actionSheet.strongDelegate = self
    }

    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
      originalDelegate?.actionSheet?(actionSheet, clickedButtonAtIndex: buttonIndex)

      source.resolve(buttonIndex)

      self.actionSheet.strongDelegate = nil
    }

    func actionSheetCancel(actionSheet: UIActionSheet) {
      originalDelegate?.actionSheetCancel?(actionSheet)
    }

    func willPresentActionSheet(actionSheet: UIActionSheet) {
      originalDelegate?.willPresentActionSheet?(actionSheet)
    }

    func didPresentActionSheet(actionSheet: UIActionSheet) {
      originalDelegate?.didPresentActionSheet?(actionSheet)
    }

    func actionSheet(actionSheet: UIActionSheet, willDismissWithButtonIndex buttonIndex: Int) {
      originalDelegate?.actionSheet?(actionSheet, willDismissWithButtonIndex: buttonIndex)
    }

    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
      originalDelegate?.actionSheet?(actionSheet, didDismissWithButtonIndex: buttonIndex)
    }
  }
}
