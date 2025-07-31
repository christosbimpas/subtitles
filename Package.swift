// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LiveSubtitlesApp",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(name: "LiveSubtitlesApp", targets: ["LiveSubtitlesApp"])
    ],
    dependencies: [
        // No external dependencies
    ],
    targets: [
        .executableTarget(
            name: "LiveSubtitlesApp",
            path: "Sources"
        )
    ]
)
