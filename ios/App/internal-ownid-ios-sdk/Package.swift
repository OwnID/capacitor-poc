// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "OwnID",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "OwnIDCoreSDK",
            targets: ["OwnIDCoreSDK"]
        ),
    ],
    targets: [
        .target(
            name: "OwnIDCoreSDK",
            dependencies: [],
            path: "ownid-core-ios-sdk",
            exclude: [
                "Tests",
            ]
        )
    ]
)
