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
            name: "AppScaffoldAnalytics",
            targets: ["AppScaffoldAnalytics"]
        ),
        .library(
            name: "AppScaffoldFirebase",
            targets: ["AppScaffoldFirebase"]
        ),
        .library(
            name: "AppScaffoldOnboarding",
            targets: ["AppScaffoldOnboarding"]
        ),
        .library(
            name: "AppScaffoldPurchases",
            targets: ["AppScaffoldPurchases"]
        ),
        .library(
            name: "AppScaffoldStore",
            targets: ["AppScaffoldStore"]
        ),
        .library(
            name: "AppScaffoldUI",
            targets: ["AppScaffoldUI"]
        ),
        .library(
            name: "AppScaffoldUtils",
            targets: ["AppScaffoldUtils"]
        ),
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
        .package(url: "https://github.com/SwiftfulThinking/SwiftfulLoadingIndicators.git", .upToNextMajor(from: "0.0.4")),
        .package(url: "https://github.com/markiv/SwiftUI-Shimmer.git", .upToNextMajor(from: "1.5.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppScaffoldCore",
            dependencies: [
                .product(name: "Resolver", package: "Resolver"),
                .product(name: "SwiftyBeaver", package: "SwiftyBeaver"),
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
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
            ],
            path: "Sources/Firebase"
        ),

        .target(
            name: "AppScaffoldAnalytics",
            dependencies: [
                "AppScaffoldCore",
                .product(name: "Mixpanel", package: "mixpanel-swift")
            ],
            path: "Sources/Analytics"
        ),

        .target(
            name: "AppScaffoldOnboarding",
            dependencies: [
                "AppScaffoldCore",
                "AppScaffoldUI"
            ],
            path: "Sources/Onboarding"
        ),

        .target(
            name: "AppScaffoldPurchases",
            dependencies: [
                "AppScaffoldCore",
                .product(name: "RevenueCat", package: "purchases-ios-spm"),
            ],
            path: "Sources/Purchases"
        ),

        .target(
            name: "AppScaffoldStore",
            dependencies: [
                "AppScaffoldCore",
                "AppScaffoldUI",
                "AppScaffoldPurchases",
                .product(name: "RevenueCatUI", package: "purchases-ios-spm")
            ],
            path: "Sources/Store"
        ),

        .target(
            name: "AppScaffoldUI",
            dependencies: [
                "AppScaffoldCore",
                "AppScaffoldAnalytics",
                .product(name: "SwiftUIX", package: "SwiftUIX"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
                .product(name: "SwiftfulLoadingIndicators", package: "SwiftfulLoadingIndicators"),
                .product(name: "Shimmer", package: "SwiftUI-Shimmer")
            ],
            path: "Sources/UI"
        ),

        .target(
            name: "AppScaffoldUtils",
            dependencies: [
                "AppScaffoldCore",
//                .product(name: "SwiftyBeaver", package: "SwiftyBeaver")
            ],
            path: "Sources/Utils"
        ),

        .testTarget(
            name: "AppScaffoldTests",
            dependencies: ["AppScaffoldCore"]
        ),
    ]
)
