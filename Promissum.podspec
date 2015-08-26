Pod::Spec.new do |s|
  s.name         = "Promissum"
  s.version      = "0.2.4"
  s.license      = "MIT"

  s.summary      = "A promises library written in Swift featuring combinators like map, flatMap, whenAll, whenAny."

  s.description  = <<-DESC
Promissum is a promise library written in Swift. It features some known functions from Function Programming like, `map` and `flatMap`.

It has useful combinators for working with promises like; `whenAll` for doing something when multiple promises complete, and `whenAny` for doing something when a single one of a list of promises completes. As well as their binary counterparts: `whenBoth` and `whenEither`.

Promissum really shines when used to combine asynchronous operations from different libraries. There are currently some basic extensions to UIKit, Alamofire and CoreDataKit, and contributions for extensions to other libraries are very welcome.
                   DESC

  s.authors           = { "Tom Lokhorst" => "tom@lokhorst.eu" }
  s.social_media_url  = "https://twitter.com/tomlokhorst"
  s.homepage          = "https://github.com/tomlokhorst/Promissum"

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'

  s.source          = { :git => "https://github.com/tomlokhorst/Promissum.git", :tag => s.version }
  s.requires_arc    = true
  s.default_subspec = "Core"

  s.subspec "Core" do |ss|
    ss.source_files  = "src/Promissum"
  end

  s.subspec "Alamofire" do |ss|
    ss.source_files = "extensions/PromissumExtensions/Alamofire+Promise.swift"
    ss.dependency "Promissum/Core"
    ss.dependency "Alamofire" # , "~> 2.0"
  end

  s.subspec "CoreDataKit" do |ss|
    ss.ios.deployment_target = '8.0'
    ss.source_files = "extensions/PromissumExtensions/CoreDataKit+Promise.swift"
    ss.dependency "Promissum/Core"
    ss.dependency "CoreDataKit" # , "~> 0.7"
  end

  s.subspec "UIKit" do |ss|
    ss.ios.deployment_target = '8.0'
    ss.source_files = "extensions/PromissumExtensions/UIKit+Promise.swift"
    ss.dependency "Promissum/Core"
  end

end
