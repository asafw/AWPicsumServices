// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "AWPicsumServices",
    platforms: [
        .iOS(.v16),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "AWPicsumServices",
            targets: ["AWPicsumServices"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AWPicsumServices",
            dependencies: []),
        .testTarget(
            name: "AWPicsumServicesTests",
            dependencies: ["AWPicsumServices"]),
        .testTarget(
            name: "AWPicsumServicesIntegrationTests",
            dependencies: ["AWPicsumServices"]),
        .executableTarget(
            name: "PicsumDemoApp",
            dependencies: ["AWPicsumServices"],
            path: "Examples/PicsumDemoApp"),
    ]
)
