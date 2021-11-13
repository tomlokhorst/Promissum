// swift-tools-version:5.1
import PackageDescription

let package = Package(
  name: "Promissum",
  platforms: [
    .macOS(.v10_12), .iOS(.v10), .tvOS(.v10), .watchOS(.v3)
  ],
  products: [
    .library(name: "Promissum", targets: ["Promissum"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "Promissum"),
    .testTarget(name: "PromissumTests", dependencies: ["Promissum"]),
  ],
  swiftLanguageVersions: [.v5]
)

