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

Alternatively, if you also want the ISO8601 Date decoder, use this subspec:

```ruby
pod 'Statham/Date-iso8601'
```

Then, run the following command:

```bash
$ pod install
```


Releases
--------

 - 0.6.1 - 2016-03-14 - Add JsonArray docodeJson & encodeJson
 - **0.6.0** - 2016-03-03 - Release as separate library
 - **0.1.0** - 2015-05-25 - Public release as part of JsonGen
 - 0.0.0 - 2014-10-11 - Initial private version for project at [Q42](http://q42.com)


Licence & Credits
-----------------

Statham is written by [Tom Lokhorst](https://twitter.com/tomlokhorst) of [Q42](http://q42.com)
and available under the [MIT license](https://github.com/tomlokhorst/Statham/blob/develop/LICENSE),
so feel free to use it in commercial and non-commercial projects.
