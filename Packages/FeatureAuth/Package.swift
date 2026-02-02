// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FeatureAuth",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "FeatureAuth",
            targets: ["FeatureAuth"]
        ),
    ],
    dependencies: [
        .package(name: "Domain", path: "../Domain"),
        .package(name: "SharedUI", path: "../SharedUI"),
        .package(name: "SharedUtils", path: "../SharedUtils"),
        // TODO: Uncomment when adding GoogleSignIn to main app target
        // .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "7.0.0"),
    ],
    targets: [
        .target(
            name: "FeatureAuth",
            dependencies: [
                "Domain",
                "SharedUI",
                "SharedUtils",
                // TODO: Uncomment when adding GoogleSignIn to main app target
                // .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
            ]
        ),
        .testTarget(
            name: "FeatureAuthTests",
            dependencies: ["FeatureAuth"]
        ),
    ]
)
