// swift-tools-version: 5.4

import PackageDescription

let package = Package(
    name: "GIFO",
    platforms: [.iOS(.v9)],
    products: [
        .library(
            name: "GIFO",
            targets: ["GIFO"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GIFO",
            path: "GIFO/Sources")
    ]
    
    
)
