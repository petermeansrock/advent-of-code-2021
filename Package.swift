// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Library",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Library",
            targets: ["Library"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/petermeansrock/advent-of-code-swift.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
        .package(url: "https://github.com/davecom/SwiftPriorityQueue.git", from: "1.3.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Library",
            dependencies: [
                .product(name: "AdventOfCode", package: "advent-of-code-swift"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "SwiftPriorityQueue", package: "SwiftPriorityQueue"),
            ],
            swiftSettings: [
                .unsafeFlags(["-enable-bare-slash-regex"]),
            ]
        ),
        .testTarget(
            name: "LibraryTests",
            dependencies: [
                "Library"
            ],
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .unsafeFlags(["-enable-bare-slash-regex"]),
            ]
        )
    ]
)
