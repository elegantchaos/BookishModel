// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BookishModelDependencies",
//    products: [
//        .library(
//            name: "BookishModelDependencies",
//            targets: ["BookishModelDependencies"])
//    ],
    dependencies: [
        .package(url: "git@github.com:elegantchaos/Logger", from: "1.0.11"),
        .package(url: "git@github.com:elegantchaos/Actions", from: "1.0.7"),
    ],
    targets: [
        .target(
            name: "BookishModelDependencies",
            dependencies: ["Logger", "Actions", "ActionsKit"]),
        .testTarget(
            name: "BookishModelTests",
            dependencies: ["BookishModelDependencies", "Actions"]),
        ],
    swiftLanguageVersions: [.v4_2]
)
