// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Swiftly",
    products: [
        .library(name: "Swiftly", targets: ["Swiftly"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "2.3.0")
    ],
    targets: [
        .target(name: "Swiftly", dependencies: ["Vapor"]),
        ]
)
