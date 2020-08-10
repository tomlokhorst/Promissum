// swift-tools-version:5.1
import PackageDescription

let package = Package(
  name: "Promissum",
  platforms: [
    .macOS(.v10_11), .iOS(.v10), .tvOS(.v9), .watchOS(.v3)
  ],
  products: [
    .library(name: "Promissum", targets: ["Promissum"]),
    .library(name: "PromissumAlamofire", targets: ["PromissumAlamofire"]),
    .library(name: "PromissumUIKit", targets: ["PromissumUIKit"]),
  ],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.1.0")
  ],
  targets: [
    .target(name: "Promissum"),
    .target(name: "PromissumAlamofire", dependencies: ["Promissum", "Alamofire"]),
    .target(name: "PromissumUIKit", dependencies: ["Promissum"]),
    .testTarget(name: "PromissumTests", dependencies: ["Promissum"]),
    .testTarget(name: "PromissumAlamofireTests", dependencies: ["PromissumAlamofire"]),
  ],
  swiftLanguageVersions: [.v5]
)

