<img src="https://cloud.githubusercontent.com/assets/75655/5077599/2f2d9f8c-6ea5-11e4-98d2-cdb72f6686a8.png" width="170" alt="Promissum">
<hr>

Promissum is a promises library written in Swift.

Example
-------

An example using the [Alamofire+Promise](https://github.com/tomlokhorst/Promissum/blob/master/extensions/PromissumExtensions/Alamofire%2BPromise.swift) extension:

    let url = "https://api.github.com/repos/tomlokhorst/Promissum"

    Alamofire.request(.GET, url).responseJSONPromise()
      .then { json in
        if let name = json["name"] as? String {
          println("This is \(name)!")
        }
      }
      .catch { e in
        println("An error occurred: \(e)")
      }


Installation
------------

Due to the lack of Swift suport in tools like [CocoaPods](http://cocoapods.org), installation of this library is a bit involved. There are five steps, which I've also demonstrated in a [screencast](https://www.youtube.com/watch?v=ow1ZE7pfBH8):

1. Add Promissum as a submodule the terminal using the command: `git submodule add https://github.com/tomlokhorst/Promissum.git`
2. Open the `Promissum/src` folder, and drag `Promissum.xcodeproj` into the file navigator of your app project.
3. In Xcode, navigate to the target configuration window by clicking on the blue project icon, and selecting the application target under the "Targets" heading in the sidebar.
4. In the tab bar at the top of that window, open the "Build Phases" panel.
5. Click on the + button at the top left of the panel and select "New Copy Files Phase". Rename this new phase to "Copy Frameworks", set the "Destination" to "Frameworks", and add `Promissum.framework`.

(These installation instructions are based on the ones for Alamofire)


Licence & Credits
-----------------

Promissum is written by [Tom Lokhorst](https://twitter.com/tomlokhorst) and available under the [MIT license](https://github.com/tomlokhorst/promissum/blob/master/LICENSE), so feel free to use it in commercial and non-commercial projects.
