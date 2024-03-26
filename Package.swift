// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "TruvSDK",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "TruvSDK",
            targets: ["TruvSDK"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "TruvSDK",
            path: "TruvSDK.xcframework")
    ],
    swiftLanguageVersions: [.v5]
)
