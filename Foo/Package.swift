// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Foo",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "Foo", targets: ["Foo"]),
    ],
    dependencies: [
        .package(name: "HotReloadSwiftUI", path: "../HotReloadSwiftUI"),
        .package(name: "HotReloadSwiftUIRunner", path: "../HotReloadSwiftUIRunner"),
    ],
    targets: [
        .executableTarget(
            name: "FooApp",
            dependencies: ["FooContent", "HotReloadSwiftUI"],
            swiftSettings: [
                .define("ENABLE_DYNAMIC_SWIFTUI"),
            ]
        ),
        .target(
            name: "Foo",
            dependencies: ["HotReloadSwiftUIRunner", "FooContent"]
        ),
        .target(
            name: "FooContent",
            dependencies: ["HotReloadSwiftUI"],
            swiftSettings: [
                // TODO: 这种条件判断可能不是最好的，看看有没有更好的判断条件
                .define("ENABLE_DYNAMIC_SWIFTUI", .when(platforms: [.macOS])),
            ]
        ),
    ]
)
