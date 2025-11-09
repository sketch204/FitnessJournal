// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Modules",
            targets: ["Core", "CoreUI", "Persistance", "Data"]),
    ],
    targets: [
        target(name: "CoreUI", dependencies: ["Core", "Data", "Utils"]),
        target(name: "Core", dependencies: ["Data", "Persistance", "Utils"]),
        target(
            name: "Persistance",
            dependencies: ["Data", "Utils"],
            resources: [
                .process("Resources")
            ]
        ),
        target(name: "Data"),
        target(name: "Utils"),

        
        testTarget(
            name: "CoreTests",
            dependencies: ["Core", "Data", "Persistance"],
            resources: [
                .process("Resources")
            ]
        ),
        testTarget(
            name: "PersistanceTests",
            dependencies: ["Persistance", "Data"]
        ),
//        .testTarget(
//            name: "CoreUITests",
//            dependencies: ["Core", "CoreUI", "Data"]
//        )
    ]
)

func target(name: String, dependencies: [Target.Dependency] = [], resources: [Resource]? = nil) -> Target {
    .target(
        name: name,
        dependencies: dependencies,
        resources: resources,
        swiftSettings: [
            .defaultIsolation(MainActor.self),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("InferIsolatedConformances"),
        ]
    )
}

func testTarget(name: String, dependencies: [Target.Dependency] = [], resources: [Resource]? = nil) -> Target {
    .testTarget(
        name: name,
        dependencies: dependencies,
        resources: resources,
        swiftSettings: [
            .defaultIsolation(MainActor.self),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("InferIsolatedConformances"),
        ]
    )
}
