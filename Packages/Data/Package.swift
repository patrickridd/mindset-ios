// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Data",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Data",
            targets: ["Data"]
        )
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../SharedUtils"),
        .package(url: "https://github.com/google/generative-ai-swift", from: "0.5.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "12.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Data",
            dependencies: [
                .product(name: "Domain", package: "Domain"),
                .product(name: "SharedUtils", package: "SharedUtils"),
                .product(name: "GoogleGenerativeAI", package: "generative-ai-swift"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
            ]
        ),
        .testTarget(
            name: "DataTests",
            dependencies: ["Data"]
        ),
    ]
)
