// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "dowyi",
  platforms: [.macOS(.v13)],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-argument-parser",
      exact: "1.2.3"
    ),
  ],
  targets: [
    .executableTarget(
      name: "dowyi",
      dependencies: [
        "Model",
        "Sanitizer",
        "Live",
        .product(
          name: "ArgumentParser",
          package: "swift-argument-parser"
        ),
      ]
    ),
    .target(
      name: "Live",
      dependencies: [
        "Utility",
      ]
    ),
    .target(
      name: "Model",
      dependencies: []
    ),
    .testTarget(
      name: "ModelTests",
      dependencies: [
        "Model",
      ]
    ),
    .target(
      name: "Sanitizer",
      dependencies: [
        "Model",
        "Utility",
      ]
    ),
    .testTarget(
      name: "SanitizerTests",
      dependencies: [
        "Model",
        "Sanitizer",
      ]
    ),
    .target(
      name: "Utility",
      dependencies: []
    ),
  ]
)
