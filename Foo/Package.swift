// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Foo",
    platforms: [
        .macOS(.v15),
        .iOS(.v15),
    ],
    products: [
        .library(name: "Foo", targets: ["Foo"]),
    ],
    dependencies: [
        .package(name: "DynamicSwiftUI", path: "../DynamicSwiftUI"),
    ],
    targets: [
        .executableTarget(
            name: "FooApp",
            dependencies: ["Foo", "DynamicSwiftUI"],
            path: "Sources/FooApp"
        ),
        .target(
            name: "Foo", 
            dependencies: ["DynamicSwiftUI"], 
            path: "Sources/Foo"
        ),
    ]
)
