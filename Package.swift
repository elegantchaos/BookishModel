// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BookishModel",
    platforms: [
        .macOS(.v10_15), .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "BookishModel",
            targets: ["BookishModel"]),
        .executable(
            name: "bkt",
            targets: ["bkt"]),
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Actions.git", from: "1.5.0"),
        .package(url: "https://github.com/elegantchaos/CommandShell.git", from: "1.1.1"),
        .package(url: "https://github.com/elegantchaos/Datastore.git", from: "1.2.3"),
        .package(url: "https://github.com/elegantchaos/Expressions.git", from: "1.0.0"),
        .package(url: "https://github.com/elegantchaos/JSONDump.git", from: "1.0.4"),
        .package(url: "https://github.com/elegantchaos/Localization.git", from: "1.0.1"),
        .package(url: "https://github.com/elegantchaos/Logger.git", from: "1.4.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "BookishModel",
            dependencies: ["Actions", "Datastore", "Expressions", "JSONDump", "Localization"]),
        .target(
            name: "bkt",
            dependencies: ["BookishModel", "CommandShell"]),
        .testTarget(
            name: "BookishModelTests",
            dependencies: ["BookishModel"]),
    ]
)
