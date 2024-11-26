// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DynamicSwiftUIRunner",
    platforms: [
        .macOS(.v14),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "DynamicSwiftUIRunner",
            targets: ["DynamicSwiftUIRunner"]),
    ],
    dependencies: [
        .package(url: "https://github.com/httpswift/swifter.git", .upToNextMajor(from: "1.5.0")),
        .package(path: "../DynamicSwiftUITransferProtocol")
    ],
    targets: [
        .target(
            name: "DynamicSwiftUIRunner",
            dependencies: [
                .product(name: "Swifter", package: "swifter"),
                .product(name: "DynamicSwiftUITransferProtocol", package: "DynamicSwiftUITransferProtocol")
            ]),
        .testTarget(
            name: "DynamicSwiftUIRunnerTests",
            dependencies: ["DynamicSwiftUIRunner"]),
    ]
)
