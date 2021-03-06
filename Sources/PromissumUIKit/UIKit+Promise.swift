//
//  UIKit+Promise.swift
//  PromissumExtensions
//
//  Created by Tom Lokhorst on 2015-01-12.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Promissum

extension UIView {
  public class func animatePromise(withDuration duration: TimeInterval, animations: @escaping () -> Void) -> Promise<Bool, Never> {
    let source = PromiseSource<Bool, Never>()

    self.animate(withDuration: duration, animations: animations, completion: source.resolve)

    return source.promise
  }

  public class func animate(withDuration duration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions, animations: @escaping () -> Void) -> Promise<Bool, Never> {
    let source = PromiseSource<Bool, Never>()

    self.animate(withDuration: duration, delay: delay, options: options, animations: animations, completion: source.resolve)

    return source.promise
  }

  public class func transition(with view: UIView, duration: TimeInterval, options: UIView.AnimationOptions, animations: @escaping () -> Void) -> Promise<Bool, Never> {
    let source = PromiseSource<Bool, Never>()

    self.transition(with: view, duration: duration, options: options, animations: animations, completion: source.resolve)

    return source.promise
  }

  public class func transition(from fromView: UIView, to toView: UIView, duration: TimeInterval, options: UIView.AnimationOptions) -> Promise<Bool, Never> {
    let source = PromiseSource<Bool, Never>()

    self.transition(from: fromView, to: toView, duration: duration, options: options, completion: source.resolve)

    return source.promise
  }

  public class func perform(_ animation: UIView.SystemAnimation, onViews views: [UIView], options: UIView.AnimationOptions, animations parallelAnimations: (() -> Void)?) -> Promise<Bool, Never> {
    let source = PromiseSource<Bool, Never>()

    self.perform(animation, on: views, options: options, animations: parallelAnimations, completion: source.resolve)

    return source.promise
  }

  public class func animateKeyframes(withDuration duration: TimeInterval, delay: TimeInterval, options: UIView.KeyframeAnimationOptions, animations: @escaping () -> Void) -> Promise<Bool, Never> {
    let source = PromiseSource<Bool, Never>()

    self.animateKeyframes(withDuration: duration, delay: delay, options: options, animations: animations, completion: source.resolve)

    return source.promise
  }
}

extension UIViewController {
  public func present(_ viewControllerToPresent: UIViewController, animated flag: Bool) -> Promise<Void, Never> {
    let source = PromiseSource<Void, Never>()

    self.present(viewControllerToPresent, animated: flag, completion: { source.resolve() })

    return source.promise
  }

  public func dismiss(animated flag: Bool) -> Promise<Void, Never> {
    let source = PromiseSource<Void, Never>()

    self.dismiss(animated: flag, completion: { source.resolve() })

    return source.promise
  }

  public func transition(from fromViewController: UIViewController, to toViewController: UIViewController, duration: TimeInterval, options: UIView.AnimationOptions, animations: (() -> Void)?) -> Promise<Bool, Never> {
    let source = PromiseSource<Bool, Never>()

    self.transition(from: fromViewController, to: toViewController, duration: duration, options: options, animations: animations, completion: source.resolve)

    return source.promise
  }
}
#endif
