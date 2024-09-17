// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "CNotifySDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "CNotifySDK",
            targets: ["CNotifySDK"]),
    ],
    dependencies: [
        .package(
            name: "Firebase",
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMajor(from: "10.0.0")
        )
    ],
    targets: [
        .target(
            name: "CNotifySDK",
            dependencies: [
                .product(name: "FirebaseMessaging", package: "Firebase")
            ],
            path: "CNotifySDK"
        ),
        .testTarget(
            name: "CNotifySDKTests",
            dependencies: ["CNotifySDK"],
            path: "CNotifySDKTests"),
    ]
)
