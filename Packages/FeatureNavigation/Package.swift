// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeatureNavigation",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FeatureNavigation",
            targets: ["FeatureNavigation"]
        ),
    ],
    dependencies: [
        .package(path: "/users/patrickridd/documents/xcodeprojects/mindset-ios/packages/domain"),
        .package(path: "/users/patrickridd/documents/xcodeprojects/mindset-ios/packages/FeatureSubscription"),
        .package(path: "/users/patrickridd/documents/xcodeprojects/mindset-ios/packages/FeatureOnboarding")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FeatureNavigation",
            dependencies: [
                .product(name: "Domain", package: "Domain"),
                .product(name: "FeatureSubscription", package: "FeatureSubscription"),
                .product(name: "FeatureOnboarding", package: "FeatureOnboarding")
            ]
        ),
        .testTarget(
            name: "FeatureNavigationTests",
            dependencies: ["FeatureNavigation"]
        ),
    ]
)
