// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SharedUtils",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SharedUtils",
            targets: ["SharedUtils"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/krzysztofzablocki/Inject.git", from: "1.2.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SharedUtils",
            dependencies: [
                .product(name: "Inject", package: "Inject")
            ]
        ),
        .testTarget(
            name: "SharedUtilsTests",
            dependencies: ["SharedUtils"]
        ),
    ]
)
