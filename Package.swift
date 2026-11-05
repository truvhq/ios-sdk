// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "TruvSDK",
    platforms: [.iOS(.v15)],
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
