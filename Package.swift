// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BookishCoreX",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "BookishCore",
            targets: ["BookishCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Logger", .branch("bookish")),
        .package(url: "https://github.com/elegantchaos/Actions", .branch("bookish")),
        .package(url: "https://github.com/elegantchaos/JSONDump", from: "1.0.4"),
        .package(url: "https://github.com/elegantchaos/Coverage", from: "1.0.4"),
        .package(url: "https://github.com/elegantchaos/CommandShell", from: "1.0.3"),
    ],
    targets: [
        .target(
            name: "BookishCoreMac",
            dependencies: ["BookishCore"]),
        .target(
            name: "BookishCoreMobile",
            dependencies: ["BookishCore"]),
        .target(
            name: "bktCore",
            dependencies: ["BookishCore", "CommandShell"]),
        .target(
            name: "BookishCore",
            dependencies: ["Logger", "LoggerKit", "Actions", "ActionsKit", "JSONDump"]),
        .testTarget(
            name: "BookishCoreTests",
            dependencies: ["BookishCore", "LoggerTestSupport"])
    ],
    swiftLanguageVersions: [.v4_2]
)
