// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "BookishModel",
    platforms: [
        .macOS(.v10_15), .iOS(.v12)
    ],
    products: [
        .library(
            name: "BookishModel",
            targets: ["BookishModel"]),
        .executable(
            name: "bkt",
            targets: ["bkt"]),
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Actions.git", from: "1.5.0"),
        .package(url: "https://github.com/elegantchaos/CommandShell.git", from: "1.1.2"),
        .package(url: "https://github.com/elegantchaos/Datastore.git", from: "1.2.3"),
        .package(url: "https://github.com/elegantchaos/Expressions.git", from: "1.0.0"),
        .package(url: "https://github.com/elegantchaos/JSONDump.git", from: "1.0.4"),
        .package(url: "https://github.com/elegantchaos/Localization.git", from: "1.0.1"),
        .package(url: "https://github.com/elegantchaos/Logger.git", from: "1.4.1"),
        .package(url: "https://github.com/elegantchaos/XCTestExtensions.git", from: "1.0.8"),
    ],
    targets: [
        .target(
            name: "BookishModel",
            dependencies: ["Actions", "Datastore", "Expressions", "JSONDump", "Localization"]),
        .target(
            name: "bkt",
            dependencies: ["BookishModel", "CommandShell"]),
        .testTarget(
            name: "BookishModelTests",
            dependencies: ["BookishModel", "XCTestExtensions"]),
    ]
)
