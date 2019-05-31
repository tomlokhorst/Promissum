Pod::Spec.new do |s|
  s.name         = "Promissum"
  s.version      = "4.0.0"
  s.license      = "MIT"

  s.summary      = "A promises library written in Swift featuring combinators like map, flatMap, whenAll, whenAny."

  s.description  = <<-DESC
Promissum is a promise library written in Swift. It features some known functions from Functional Programming like, `map` and `flatMap`.

It has useful combinators for working with promises like; `whenAll` for doing something when multiple promises complete, and `whenAny` for doing something when a single one of a list of promises completes. As well as their binary counterparts: `whenBoth` and `whenEither`.

Promissum really shines when used to combine asynchronous operations from different libraries. There are currently some basic extensions to UIKit and Alamofire, and contributions for extensions to other libraries are very welcome.
                   DESC

  s.authors           = { "Tom Lokhorst" => "tom@lokhorst.eu" }
  s.social_media_url  = "https://twitter.com/tomlokhorst"
  s.homepage          = "https://github.com/tomlokhorst/Promissum"

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '3.0'

  s.source          = { :git => "https://github.com/tomlokhorst/Promissum.git", :tag => s.version }
  s.requires_arc    = true
  s.default_subspec = "Core"
  s.swift_version   = "5.0"

  s.subspec "Core" do |ss|
    ss.source_files  = "Sources/Promissum"
  end

  s.subspec "Alamofire" do |ss|
    ss.source_files = "extensions/PromissumExtensions/Alamofire+Promise.swift"
    ss.dependency "Promissum/Core"
    ss.dependency "Alamofire", "~> 4.0"
  end

  s.subspec "UIKit" do |ss|
    ss.ios.deployment_target = '9.0'
    ss.source_files = "extensions/PromissumExtensions/UIKit+Promise.swift"
    ss.dependency "Promissum/Core"
  end

end
