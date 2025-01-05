// swift-tools-version: 6.0
import PackageDescription

// FIXME: Xcode can not open same package in different project.So the Example and Foo can only open one of them at the same time.
let package = Package(
    name: "HotReloadSwiftUITransferProtocol",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "HotReloadSwiftUITransferProtocol",
            targets: ["HotReloadSwiftUITransferProtocol"]
        ),
    ],
    targets: [
        .target(
            name: "HotReloadSwiftUITransferProtocol"),
        .testTarget(
            name: "HotReloadSwiftUITransferProtocolTests",
            dependencies: ["HotReloadSwiftUITransferProtocol"]
        ),
    ]
)
