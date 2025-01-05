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
        .package(url: "https://github.com/httpswift/swifter.git", .upToNextMajor(from: "1.5.0")),
        .package(path: "../HotReloadSwiftUITransferProtocol"),
    ],
    targets: [
        .target(
            name: "HotReloadSwiftUIRunner",
            dependencies: [
                .product(name: "Swifter", package: "swifter"),
                .product(name: "HotReloadSwiftUITransferProtocol", package: "HotReloadSwiftUITransferProtocol"),
            ]
        ),
        .testTarget(
            name: "HotReloadSwiftUIRunnerTests",
            dependencies: ["HotReloadSwiftUIRunner"]
        ),
    ]
)
