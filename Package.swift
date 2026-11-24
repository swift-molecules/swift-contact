// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-contact",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "Contact", targets: ["Contact"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-energy.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-force.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-modulus.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-numeric.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-poisson.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-space.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Contact",
            dependencies: [
                .product(name: "Energy", package: "swift-energy"),
                .product(name: "Force", package: "swift-force"),
                .product(name: "Modulus", package: "swift-modulus"),
                .product(name: "Numeric", package: "swift-numeric"),
                .product(name: "Poisson", package: "swift-poisson"),
                .product(name: "Space", package: "swift-space"),
            ]
        ),
        .testTarget(
            name: "Contact Tests",
            dependencies: [
                .target(name: "Contact")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .strictMemorySafety(),
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("InferIsolatedConformances"),
            .enableExperimentalFeature("Lifetimes"),
            .treatAllWarnings(as: .error),
        ]
}
