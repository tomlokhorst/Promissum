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


Licence & Credits
-----------------

Promissum is written by [Tom Lokhorst](https://twitter.com/tomlokhorst) and available under the [MIT license](https://github.com/tomlokhorst/promissum/blob/master/LICENSE), so feel free to use it in commercial and non-commercial projects.
