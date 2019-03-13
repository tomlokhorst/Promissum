// swift-tools-version:4.2
import PackageDescription

let package = Package(
  name: "Promissum",
  products: [
    .library(name: "Promissum", targets: ["Promissum"]),
  ],
  dependencies: [],
  targets: [
    .target(name: "Promissum"),
    .testTarget(name: "PromissumTests", dependencies: ["Promissum"]),
  ]
)

