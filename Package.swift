// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "TruvSDKPackage",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "TruvSDKPackage",
            targets: ["TruvSDKPackage", "TruvSDK"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TruvSDKPackage",
            dependencies: []
        ),
        .binaryTarget(
            name: "TruvSDK",
            path: "TruvSDK.xcframework"
        )
    ],
    swiftLanguageVersions: [.v5]
)
