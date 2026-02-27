// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SharedUI",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SharedUI",
            targets: ["SharedUI"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.5.0"),
        .package(path: "../SharedUtils")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SharedUI",
            dependencies: [
                .product(name: "Lottie", package: "lottie-spm"),
                .product(name: "SharedUtils", package: "SharedUtils")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SharedUITests",
            dependencies: ["SharedUI"]
        ),
    ]
)
