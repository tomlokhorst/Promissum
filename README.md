<img src="https://cloud.githubusercontent.com/assets/75655/5077599/2f2d9f8c-6ea5-11e4-98d2-cdb72f6686a8.png" width="170" alt="Promissum">
<hr>

Promissum is a promises library written in Swift. It features some known functions from Function Programming like, `map` and `flatMap`.

It has useful combinators for working with promises like; `whenAll` for doing something when multiple promises complete, and `whenAny` for doing something when a single one of a list of promises completes. As well as their binary counterparts: `whenBoth` and `whenEither`.

Promissum really shines when used to combine asynchronous operations from different libraries. There are currently some basic extensions to UIKit, Alamofire and CoreDataKit, and contributions for extensions to other libraries are very welcome.

This library has an extensive set of regression tests, documentation, and has been used for months in several high profile production apps at [Q42](http://q42.com/swift).


Example
-------

This example demonstrates the [Alamofire+Promise](https://github.com/tomlokhorst/Promissum/blob/develop/extensions/PromissumExtensions/Alamofire%2BPromise.swift) and [CoreDataKit+Promise](https://github.com/tomlokhorst/Promissum/blob/develop/extensions/PromissumExtensions/CoreDataKit%2BPromise.swift) extensions.

In this example, JSON data is loaded from the Github API. It is then parsed, and stored into CoreData.
If both those succeed the result is shown to the user, if either of those fail, a description of the error is shown to the user.

```swift
let url = "https://api.github.com/repos/tomlokhorst/Promissum"
Alamofire.request(.GET, url).responseJSONPromise()
  .map(parseJson)
  .flatMap(storeInCoreData)
  .then { project in

    // Show project name and description
    self.nameLabel.text = project.name
    self.descriptionLabel.text = project.descr

    UIView.animateWithDuration(0.5) {
      self.detailsView.alpha = 1
    }
  }
  .catch { e in

    // Either an Alamofire error or a CoreData error occured
    self.errorLabel.text = e.localizedDescription
    self.errorView.alpha = 1
  }
```

See [FadeExample/ViewController.swift](https://github.com/tomlokhorst/Promissum/blob/develop/examples/FadeExample/FadeExample/ViewController.swift) for an extended version of this example.


Cancellation
------------

Promissum does not support cancellation, because cancellation does not work well with promises. Promises are future _values_, values can't be cancelled. If you do need cancellation (quite often useful), take a look at Tasks or Rx instead of promises. I don't have experience with any Swift Task/Rx libraries, so I can't recommend a specific one.

Although, if you're looking at adding cancellation to a _PromiseSource_, you could use the [swift-cancellationtoken](https://github.com/tomlokhorst/swift-cancellationtoken) library I wrote. This is orthogonal to promises, however.


Combinators
-----------

Listed below are some of the methods and functions provided this library. More documentation is available inline.

### Instance methods on Promise

* `.map(transform: Value -> NewValue)`  
  Returns a Promise containing the result of mapping a function over the promise value.

* `.flatMap(transform: Value -> Promise<NewValue, Error>)`  
  Returns the flattened result of mapping a function over the promise value.

* `.mapError(transform: Error -> NewError)`  
  Returns a Promise containing the result of mapping a function over the promise error.

* `.flatMapError(transform: Error -> Promise<Value, NewError>)`  
  Returns the flattened result of mapping a function over the promise error.


### Functions for dealing with Promises

* `flatten(promise: Promise<Promise<Value, Error>, Error>)`  
  Flattens a nested Promise of Promise into a single Promise.

* `whenBoth(promiseA: Promise<A, Error>, _ promiseB: Promise<B, Error>)`  
  Creates a Promise that resolves when both arguments to `whenBoth` resolve.

* `whenAll(promises: [Promise<Value, Error>])`  
  Creates a Promise that resolves when all provided Promises resolve.

* `whenEither(promise1: Promise<Value, Error>, _ promise2: Promise<Value, Error>)`  
  Creates a Promise that resolves when either argument to resolves.

* `whenAny(promises: [Promise<Value, Error>])`  
  Creates a Promise that resolves when any of the argument Promises resolves.


Installation
------------

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.
You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Promissum into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

pod 'Promissum', '~> 0.3.0'
```

Then, run the following command:

```bash
$ pod install
```


Releases
--------

 - **0.3.0** - 2015-09-11 - Swift 2 support, added custom error types
 - 0.2.4 - 2015-05-31 - Fixed examples. Updated CoreDataKit+Promise
 - 0.2.3 - 2015-04-13 - Swift 1.2 support
 - 0.2.2 - 2015-03-01 - Mac OS X support
 - 0.2.1 - 2015-02-16 - Update for new CoreDataKit version
 - **0.2.0** - 2015-02-15 - Side-effects happen in a better order. Regression tests added.
 - 0.1.1 - 2015-05-31 - `whenAnyFinalized` combinator added
 - **0.1.0** - 2015-01-27 - Initial public release
 - 0.0.0 - 2014-10-12 - Initial privat version for project at [Q42](http://q42.com)


Licence & Credits
-----------------

Promissum is written by [Tom Lokhorst](https://twitter.com/tomlokhorst) and available under the [MIT license](https://github.com/tomlokhorst/promissum/blob/master/LICENSE), so feel free to use it in commercial and non-commercial projects.
