// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BookishModelDependencies",
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Logger", from: "1.1.1"),
        .package(url: "https://github.com/elegantchaos/Actions", from: "1.2.0"),
        .package(url: "https://github.com/elegantchaos/JSONDump", from: "1.0.3"),
        .package(url: "https://github.com/elegantchaos/Coverage", from: "1.0.1"),
    ],
    targets: [
        .target(
            name: "BookishModelDependencies",
            dependencies: ["Logger", "Actions"]),
        .target(
            name: "BookishCore",
            dependencies: ["Logger", "Actions", "ActionsKit", "JSONDump", "LoggerTestSupport"]),
        ],
    swiftLanguageVersions: [.v4_2]
)
