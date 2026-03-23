// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "FeatureStart",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "FeatureStart",
            targets: ["FeatureStart"]
        )
    ],
    dependencies: [
        .package(name: "Domain", path: "../Domain"),
        .package(name: "SharedUI", path: "../SharedUI"),
        .package(name: "SharedUtils", path: "../SharedUtils"),
        .package(name: "SharedLocalization", path: "../SharedLocalization"),
    ],
    targets: [
        .target(
            name: "FeatureStart",
            dependencies: [
                "Domain",
                "SharedUI",
                "SharedUtils",
                .product(name: "SharedLocalization", package: "SharedLocalization"),
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .defaultIsolation(MainActor.self)
            ]
        ),
        .testTarget(
            name: "FeatureStartTests",
            dependencies: ["FeatureStart"]
        ),
    ]
)
