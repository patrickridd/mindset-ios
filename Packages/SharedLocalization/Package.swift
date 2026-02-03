// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SharedLocalization",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SharedLocalization",
            targets: ["SharedLocalization"]
        ),
    ],
    targets: [
        .target(
            name: "SharedLocalization",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SharedLocalizationTests",
            dependencies: ["SharedLocalization"]
        ),
    ]
)
