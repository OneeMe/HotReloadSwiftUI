// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "HotReloadSwiftUI",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
  ],
  dependencies: [
    .package(path: "../HotReloadSwiftUIRunner"),
    .package(path: "../HotReloadSwiftUITransferProtocol"),
    .package(path: "../HotReloadSwiftUI"),
    .package(path: "../HotReloadSwiftUIMacros"),
  ]
)
