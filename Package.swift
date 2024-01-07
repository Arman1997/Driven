// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Driven",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Driven",
            targets: ["Driven"]),
    ],
    dependencies: [
      .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.2"),
      .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.9.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Driven",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
            ]
        ),
        .testTarget(
            name: "DrivenTests",
            dependencies: ["Driven"]),
    ]
)
