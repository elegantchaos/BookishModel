// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BookishCore",
    platforms: [
        .macOS(.v10_13), .iOS(.v12),
    ],
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
        .package(url: "https://github.com/elegantchaos/Logger.git", from: "1.3.6"),
        .package(url: "https://github.com/elegantchaos/Actions.git", from: "1.3.5"),
        .package(url: "https://github.com/elegantchaos/CommandShell.git", from: "1.1.0"),
        .package(url: "https://github.com/elegantchaos/Expressions.git", from: "1.0.0"),
        .package(url: "https://github.com/elegantchaos/JSONDump.git", from: "1.0.4"),
        .package(url: "https://github.com/elegantchaos/SketchX.git", from: "1.0.8"),
        .package(url: "https://github.com/elegantchaos/ReleaseTools.git", from: "1.0.1"),
        .package(url: "https://github.com/elegantchaos/Coverage.git", from: "1.0.6"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "BookishCore",
            dependencies: ["Logger", "LoggerKit", "Actions", "ActionsKit", "Expressions", "JSONDump"]),
        .target(
            name: "Tools",
            dependencies: ["sketchx", "rt", "coverage"]),
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
