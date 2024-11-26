// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DynamicSwiftUI",
    platforms: [
        .macOS(.v14),
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DynamicSwiftUI",
            targets: ["DynamicSwiftUI"]),
    ],
    dependencies: [
        .package(name: "DynamicSwiftUIMacros", path: "../DynamicSwiftUIMacros"),
        .package(name: "DynamicSwiftUITransferProtocol", path: "../DynamicSwiftUITransferProtocol")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DynamicSwiftUI",
            dependencies: ["DynamicSwiftUITransferProtocol"]),
        .testTarget(
            name: "DynamicSwiftUITests",
            dependencies: ["DynamicSwiftUI"]
        ),
    ]
)
