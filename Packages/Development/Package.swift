// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Development",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Development",
            targets: ["Development"]
        )
    ],
    dependencies: [
        .package(path: "../Data"),
        .package(path: "../Domain"),
        .package(path: "../SharedLocalization"),
        .package(path: "../SharedUI"),
        .package(path: "../SharedUtils"),
    ],
    targets: [
        .target(
            name: "Development",
            dependencies: [
                .product(name: "Data", package: "Data"),
                .product(name: "Domain", package: "Domain"),
                .product(name: "SharedLocalization", package: "SharedLocalization"),
                .product(name: "SharedUI", package: "SharedUI"),
                .product(name: "SharedUtils", package: "SharedUtils"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "DevelopmentTests",
            dependencies: ["Development"]
        ),
    ]
)
