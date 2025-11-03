// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "scd",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(path: "Libs/swift-argument-parser"),
        .package(path: "Libs/swift-soup")
    ],
    targets: [
        .executableTarget(
            name: "scd",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftSoup", package: "swift-soup")
            ]
        ),
    ]
)
