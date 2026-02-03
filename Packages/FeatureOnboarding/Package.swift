// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeatureOnboarding",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FeatureOnboarding",
            targets: ["FeatureOnboarding"]
        ),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../Data"),
        .package(path: "../SharedUtils"),
        .package(path: "../SharedUI"),
        .package(path: "../SharedLocalization"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FeatureOnboarding",
            dependencies: [
                .product(name: "Domain", package: "Domain"),
                .product(name: "Data", package: "Data"),
                .product(name: "SharedUtils", package: "SharedUtils"),
                .product(name: "SharedUI", package: "SharedUI"),
                .product(name: "SharedLocalization", package: "SharedLocalization"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "FeatureOnboardingTests",
            dependencies: ["FeatureOnboarding"]
        ),
    ]
)
