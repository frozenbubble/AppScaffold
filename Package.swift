// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppScaffold",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AppScaffoldCore",
            targets: ["AppScaffoldCore"]
        ),
        .library(
            name: "AppScaffoldFirebase",
            targets: ["AppScaffoldFirebase"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/mixpanel/mixpanel-swift", .upToNextMajor(from: "4.3.0")),
        .package(url: "https://github.com/hmlongco/Resolver.git", .upToNextMajor(from: "1.5.1")),
        .package(url: "https://github.com/RevenueCat/purchases-ios-spm.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", .upToNextMajor(from: "0.2.3")),
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", .upToNextMajor(from: "2.4.1")),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", .upToNextMajor(from: "11.6.0")),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", .upToNextMajor(from: "8.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppScaffoldCore",
            dependencies: [
                .product(name: "Mixpanel", package: "mixpanel-swift"),
                .product(name: "Resolver", package: "Resolver"),
                .product(name: "RevenueCat", package: "purchases-ios-spm"),
                .product(name: "RevenueCatUI", package: "purchases-ios-spm"),
                .product(name: "SwiftUIX", package: "SwiftUIX"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
                .product(name: "SwiftyBeaver", package: "SwiftyBeaver"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "GoogleSignInSwift", package: "GoogleSignIn-iOS"),
            ],
            path: "Sources/Core"
        ),
        .target(
            name: "AppScaffoldFirebase",
            dependencies: [
                "AppScaffoldCore",
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFunctions", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
//                .product(name: "Resolver", package: "Resolver"),
            ],
            path: "Sources/Firebase"
        ),
        .testTarget(
            name: "AppScaffoldTests",
            dependencies: ["AppScaffoldCore"]
        ),
    ]
)
