<img src="https://cloud.githubusercontent.com/assets/75655/13197297/538d3f90-d7ea-11e5-8967-9c519785c2bf.png" width="125" alt="Statham">
<hr>

Statham is a Json decoding library for Swift. It is used by the [JsonGen](https://github.com/tomlokhorst/swift-json-gen) code generator.

This library has been used since 2014 for several high profile production apps at [Q42](http://q42.com/swift).


# CocoaHeadsNL presentation

Tom Lokhorst presented at the January 2016 CocoaHeadsNL meetup.
Comparing several Json decoding libraries for Swift and talking about code generation with JsonGen.

<a href="https://vimeo.com/152054122"><img src="https://i.vimeocdn.com/video/551951015.jpg?mw=960&mh=540" width="560"></a>


Installation
------------

### CocoaPods

Specify Statham in your Podfile:

```ruby
pod 'Statham'
```

Alternatively, if you also want the ISO8601 Date decoder, or the Alamofire or Promissum extensions.
Use any or multiple of these subspecs:

```ruby
pod 'Statham/Date-iso8601'
pod 'Statham/Alamofire'
pod 'Statham/Alamofire+Promissum'
```

Then, run the following command:

```bash
$ pod install
```


Releases
--------

 - 1.2.0 - 2017-01-17 - Fix `ValueOrJsonError` decoders for Swift 3
 - 1.1.0 - 2017-01-03 - Add `Alamofire` and `Alamofire+Promissum` subspecs
 - **1.0.0** - 2016-09-30 - Swift 3 support
 - 0.6.2 - 2016-09-03 - Add ValueOrJsonError enum
 - 0.6.1 - 2016-03-14 - Add JsonArray docodeJson & encodeJson
 - **0.6.0** - 2016-03-03 - Release as separate library
 - **0.1.0** - 2015-05-25 - Public release as part of JsonGen
 - 0.0.0 - 2014-10-11 - Initial private version for project at [Q42](http://q42.com)


Licence & Credits
-----------------

Statham is written by [Tom Lokhorst](https://twitter.com/tomlokhorst) of [Q42](http://q42.com)
and available under the [MIT license](https://github.com/tomlokhorst/Statham/blob/develop/LICENSE),
so feel free to use it in commercial and non-commercial projects.
