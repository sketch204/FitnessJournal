// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Modules",
            targets: ["Core", "CoreUI", "Data"]),
    ],
    targets: [
        .target(name: "Core", dependencies: ["Data"]),
        .target(name: "CoreUI", dependencies: ["Core", "Data"]),
        .target(name: "Data"),
        
        
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core", "Data"]
        ),
        .testTarget(
            name: "CoreUITests",
            dependencies: ["Core", "CoreUI", "Data"]
        )
    ]
)
