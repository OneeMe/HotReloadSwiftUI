// swift-tools-version: 6.0
import PackageDescription

// FIXME: Xcode can not open same package in different project.So the Example and Foo can only open one of them at the same time.
let package = Package(
    name: "DynamicSwiftUITransferProtocol",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "DynamicSwiftUITransferProtocol",
            targets: ["DynamicSwiftUITransferProtocol"]),
    ],
    targets: [
        .target(
            name: "DynamicSwiftUITransferProtocol"),
        .testTarget(
            name: "DynamicSwiftUITransferProtocolTests",
            dependencies: ["DynamicSwiftUITransferProtocol"]),
    ]
)
