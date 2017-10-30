//
//  UIKit+Promise.swift
//  PromissumExtensions
//
//  Created by Tom Lokhorst on 2015-01-12.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import UIKit

extension UIView {
  public class func animatePromise(withDuration duration: TimeInterval, animations: @escaping () -> Void) -> Promise<Bool, NoError> {
    let source = PromiseSource<Bool, NoError>()

    self.animate(withDuration: duration, animations: animations, completion: source.resolve)

    return source.promise
  }

  public class func animate(withDuration duration: TimeInterval, delay: TimeInterval, options: UIViewAnimationOptions, animations: @escaping () -> Void) -> Promise<Bool, NoError> {
    let source = PromiseSource<Bool, NoError>()

    self.animate(withDuration: duration, delay: delay, options: options, animations: animations, completion: source.resolve)

    return source.promise
  }

  public class func transition(with view: UIView, duration: TimeInterval, options: UIViewAnimationOptions, animations: @escaping () -> Void) -> Promise<Bool, NoError> {
    let source = PromiseSource<Bool, NoError>()

    self.transition(with: view, duration: duration, options: options, animations: animations, completion: source.resolve)

    return source.promise
  }

  public class func transition(from fromView: UIView, to toView: UIView, duration: TimeInterval, options: UIViewAnimationOptions) -> Promise<Bool, NoError> {
    let source = PromiseSource<Bool, NoError>()

    self.transition(from: fromView, to: toView, duration: duration, options: options, completion: source.resolve)

    return source.promise
  }

  public class func perform(_ animation: UISystemAnimation, onViews views: [UIView], options: UIViewAnimationOptions, animations parallelAnimations: (() -> Void)?) -> Promise<Bool, NoError> {
    let source = PromiseSource<Bool, NoError>()

    self.perform(animation, on: views, options: options, animations: parallelAnimations, completion: source.resolve)

    return source.promise
  }

  public class func animateKeyframes(withDuration duration: TimeInterval, delay: TimeInterval, options: UIViewKeyframeAnimationOptions, animations: @escaping () -> Void) -> Promise<Bool, NoError> {
    let source = PromiseSource<Bool, NoError>()

    self.animateKeyframes(withDuration: duration, delay: delay, options: options, animations: animations, completion: source.resolve)

    return source.promise
  }
}

extension UIViewController {
  public func present(_ viewControllerToPresent: UIViewController, animated flag: Bool) -> Promise<Void, NoError> {
    let source = PromiseSource<Void, NoError>()

    self.present(viewControllerToPresent, animated: flag, completion: { source.resolve() })

    return source.promise
  }

  public func dismiss(animated flag: Bool) -> Promise<Void, NoError> {
    let source = PromiseSource<Void, NoError>()

    self.dismiss(animated: flag, completion: { source.resolve() })

    return source.promise
  }

  public func transition(from fromViewController: UIViewController, to toViewController: UIViewController, duration: TimeInterval, options: UIViewAnimationOptions, animations: (() -> Void)?) -> Promise<Bool, NoError> {
    let source = PromiseSource<Bool, NoError>()

    self.transition(from: fromViewController, to: toViewController, duration: duration, options: options, animations: animations, completion: source.resolve)

    return source.promise
  }
}

var associatedObjectHandle: UInt8 = 0
let associationPolicy = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC

// UIAlertView is deprecated per iOS 9, however this extension is here for convenience
@available(iOS, introduced: 2.0, deprecated: 9.0, message: "UIAlertView is deprecated. Use UIAlertController with a preferredStyle of UIAlertControllerStyleAlert instead")
extension UIAlertView {
  var strongDelegate: AlertViewDelegate? {
    get {
      return (objc_getAssociatedObject(self, &associatedObjectHandle) as? AlertViewDelegate)
    }
    set {
      objc_setAssociatedObject(self, &associatedObjectHandle, newValue, associationPolicy)
    }
  }

  public func showPromise() -> Promise<Int, NoError> {
    let source = PromiseSource<Int, NoError>()
    let originalDelegate = self.delegate as? UIAlertViewDelegate

    self.delegate = AlertViewDelegate(source: source, alertView: self, originalDelegate: originalDelegate)
    self.show()

    return source.promise
  }

  internal class AlertViewDelegate: NSObject, UIAlertViewDelegate {
    let source: PromiseSource<Int, NoError>
    let alertView: UIAlertView
    let originalDelegate: UIAlertViewDelegate?

    init(source: PromiseSource<Int, NoError>, alertView: UIAlertView, originalDelegate: UIAlertViewDelegate?) {
      self.source = source
      self.alertView = alertView
      self.originalDelegate = originalDelegate

      super.init()

      self.alertView.strongDelegate = self
    }

    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
      originalDelegate?.alertView?(alertView, clickedButtonAt: buttonIndex)

      source.resolve(buttonIndex)
    }

    func alertViewCancel(_ alertView: UIAlertView) {
      originalDelegate?.alertViewCancel?(alertView)
    }

    func willPresent(_ alertView: UIAlertView) {
      originalDelegate?.willPresent?(alertView)
    }

    func didPresent(_ alertView: UIAlertView) {
      originalDelegate?.didPresent?(alertView)
    }

    func alertView(_ alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
      originalDelegate?.alertView?(alertView, willDismissWithButtonIndex: buttonIndex)
    }

    func alertView(_ alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
      originalDelegate?.alertView?(alertView, didDismissWithButtonIndex: buttonIndex)
      self.alertView.strongDelegate = nil
    }

    func alertViewShouldEnableFirstOtherButton(_ alertView: UIAlertView) -> Bool {
      return originalDelegate?.alertViewShouldEnableFirstOtherButton?(alertView) ?? false
    }
  }
}

// UIActionSheet is deprecated per iOS 8, however this extension is here for convenience
@available(iOS, deprecated: 8.3, message: "'UIActionSheet' was deprecated in iOS 8.3: UIActionSheet is deprecated. Use UIAlertController with a preferredStyle of UIAlertControllerStyleActionSheet instead")
extension UIActionSheet {
  var strongDelegate: ActionSheetDelegate? {
    get {
      return (objc_getAssociatedObject(self, &associatedObjectHandle) as? ActionSheetDelegate)
    }
    set {
      objc_setAssociatedObject(self, &associatedObjectHandle, newValue, associationPolicy)
    }
  }

  public func showPromise(in view: UIView) -> Promise<Int, NoError> {
    let source = PromiseSource<Int, NoError>()
    let originalDelegate = self.delegate

    self.delegate = ActionSheetDelegate(source: source, actionSheet: self, originalDelegate: originalDelegate)
    self.show(in: view)

    return source.promise
  }

  internal class ActionSheetDelegate: NSObject, UIActionSheetDelegate {
    let source: PromiseSource<Int, NoError>
    let actionSheet: UIActionSheet
    let originalDelegate: UIActionSheetDelegate?

    init(source: PromiseSource<Int, NoError>, actionSheet: UIActionSheet, originalDelegate: UIActionSheetDelegate?) {
      self.source = source
      self.actionSheet = actionSheet
      self.originalDelegate = originalDelegate

      super.init()

      self.actionSheet.strongDelegate = self
    }

    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
      originalDelegate?.actionSheet?(actionSheet, clickedButtonAt: buttonIndex)

      source.resolve(buttonIndex)
    }

    func actionSheetCancel(_ actionSheet: UIActionSheet) {
      originalDelegate?.actionSheetCancel?(actionSheet)
    }

    func willPresent(_ actionSheet: UIActionSheet) {
      originalDelegate?.willPresent?(actionSheet)
    }

    func didPresent(_ actionSheet: UIActionSheet) {
      originalDelegate?.didPresent?(actionSheet)
    }

    func actionSheet(_ actionSheet: UIActionSheet, willDismissWithButtonIndex buttonIndex: Int) {
      originalDelegate?.actionSheet?(actionSheet, willDismissWithButtonIndex: buttonIndex)
    }

    func actionSheet(_ actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
      originalDelegate?.actionSheet?(actionSheet, didDismissWithButtonIndex: buttonIndex)
      self.actionSheet.strongDelegate = nil
    }
  }
}
