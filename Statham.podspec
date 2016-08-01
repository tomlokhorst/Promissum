Pod::Spec.new do |s|
  s.name         = "Statham"
  s.version      = "0.6.1"
  s.license      = "MIT"

  s.summary      = "Swift library for decoding Json. Used by JsonGen code generator."

  s.description  = <<-DESC
    Statham is a library written in Swift for encoding and decoding Json.
    The JsonGen code generator is used to generate Statham code.
                   DESC

  s.authors           = { "Tom Lokhorst" => "tom@lokhorst.eu" }
  s.social_media_url  = "https://twitter.com/tomlokhorst"
  s.homepage          = "https://github.com/tomlokhorst/Statham"

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'

  s.source          = { :git => "https://github.com/tomlokhorst/Statham.git", :tag => s.version }
  s.requires_arc    = true
  s.default_subspec = "Core"

  s.subspec "Core" do |ss|
    ss.source_files  = "Sources"
  end

  s.subspec "Date-iso8601" do |ss|
    ss.source_files = "extensions/Date+JsonGen.swift"
    ss.dependency "Statham/Core"
  end
end
