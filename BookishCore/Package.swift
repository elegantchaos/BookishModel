// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BookishCore",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "BookishCore",
            targets: ["BookishCore"]),
        .library(
            name: "BookishCoreTestSupport",
            targets: ["BookishCoreTestSupport"]),
        .library(
            name: "bktCore",
            targets: ["bktCore"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/elegantchaos/Logger", from: "1.3.5"),
        .package(url: "https://github.com/elegantchaos/Actions", from: "1.3.3"),
        .package(url: "https://github.com/elegantchaos/CommandShell", from: "1.0.5"),
        .package(url: "https://github.com/elegantchaos/Expressions", from: "1.0.0"),
        .package(url: "https://github.com/elegantchaos/JSONDump", from: "1.0.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "BookishCore",
            dependencies: ["Logger", "LoggerKit", "Actions", "Expressions", "JSONDump"]),
        .target(
            name: "bktCore",
            dependencies: ["CommandShell"]),
        .target(
            name: "BookishCoreTestSupport",
            dependencies: ["LoggerTestSupport"]),
        .testTarget(
            name: "BookishCoreTests",
            dependencies: ["BookishCore"]),
    ]
)
