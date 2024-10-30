// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "slox",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // other dependencies
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(path: "./lib"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "slox",
            dependencies: [
                .product(name: "lib", package: "lib")
            ]
        )
    ]
)
