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
        // Add any dependencies here, like Firebase
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMajor(from: "10.4.0")
        )
    ],
    targets: [
        .target(
            name: "CNotifySDK",
            dependencies: [
                .product(name: "FirebaseMessaging", package: "Firebase"),
            ]),
        .testTarget(
            name: "CNotifySDKTests",
            dependencies: ["CNotifySDK"]),
    ]
)
