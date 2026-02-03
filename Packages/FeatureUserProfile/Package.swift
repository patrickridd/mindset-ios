// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeatureUserProfile",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "FeatureUserProfile",
            targets: ["FeatureUserProfile"]
        ),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../SharedUI"),
        .package(path: "../SharedUtils"),
        .package(path: "../SharedLocalization"),
    ],
    targets: [
        .target(
            name: "FeatureUserProfile",
            dependencies: [
                .product(name: "Domain", package: "Domain"),
                .product(name: "SharedUI", package: "SharedUI"),
                .product(name: "SharedUtils", package: "SharedUtils"),
                .product(name: "SharedLocalization", package: "SharedLocalization"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "FeatureUserProfileTests",
            dependencies: ["FeatureUserProfile"]
        ),
    ]
)
