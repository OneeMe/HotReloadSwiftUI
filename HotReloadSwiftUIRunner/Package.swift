// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HotReloadSwiftUIRunner",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "HotReloadSwiftUIRunner",
            targets: ["HotReloadSwiftUIRunner"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/OneeMe/HotReloadSwiftUITransferProtocol", branch: "main"),
    ],
    targets: [
        .target(
            name: "HotReloadSwiftUIRunner",
            dependencies: [
                .product(name: "HotReloadSwiftUITransferProtocol", package: "HotReloadSwiftUITransferProtocol"),
            ]
        ),
        .testTarget(
            name: "HotReloadSwiftUIRunnerTests",
            dependencies: ["HotReloadSwiftUIRunner"]
        ),
    ]
)
