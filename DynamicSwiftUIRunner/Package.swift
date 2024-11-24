// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DynamicSwiftUIRunner",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "DynamicSwiftUIRunner",
            targets: ["DynamicSwiftUIRunner"]),
    ],
    dependencies: [
        .package(url: "https://github.com/httpswift/swifter.git", .upToNextMajor(from: "1.5.0"))
    ],
    targets: [
        .target(
            name: "DynamicSwiftUIRunner",
            dependencies: [
                .product(name: "Swifter", package: "swifter"),
            ]),
        .testTarget(
            name: "DynamicSwiftUIRunnerTests",
            dependencies: ["DynamicSwiftUIRunner"]),
    ]
)
