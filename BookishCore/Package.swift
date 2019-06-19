// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "BookishCore",
    
    platforms: [
        .macOS(.v10_13), .iOS(.v12),
    ],
    
    products: [
        .library(
            // stuff requireed by BookishModel
            name: "BookishCore",
            targets: ["BookishCore"]),
        .library(
            // stuff required by the BookishModel tests
            name: "BookishCoreTestSupport",
            targets: ["BookishCoreTestSupport"]),
        .library(
            // stuff required by the bkt tool
            name: "bktCore",
            targets: ["bktCore"]),
    ],
    
    dependencies: [
        // model dependencies
        .package(url: "https://github.com/elegantchaos/Logger.git", from: "1.3.6"),
        .package(url: "https://github.com/elegantchaos/Actions.git", from: "1.3.5"),
        .package(url: "https://github.com/elegantchaos/CommandShell.git", from: "1.1.0"),
        .package(url: "https://github.com/elegantchaos/Expressions.git", from: "1.0.0"),
        .package(url: "https://github.com/elegantchaos/JSONDump.git", from: "1.0.4"),
        
        // tool dependencies
        .package(url: "https://github.com/elegantchaos/SketchX.git", from: "1.0.8"),
        .package(url: "https://github.com/elegantchaos/ReleaseTools.git", from: "1.0.2"),
        .package(url: "https://github.com/elegantchaos/Coverage.git", from: "1.0.6"),
    ],
    
    targets: [
        .target(
            // stuff required by BookishModel
            name: "BookishCore",
            dependencies: ["Logger", "LoggerKit", "Actions", "ActionsKit", "Expressions", "JSONDump"]),
        .target(
            // stuff required by bkt
            name: "bktCore",
            dependencies: ["CommandShell"]),
        .target(
            // stuff required by the unit tests
            name: "BookishCoreTestSupport",
            dependencies: ["LoggerTestSupport"]),
        .target(
            // tools used to build and/or test BookishModel
            name: "Tools",
            dependencies: ["sketchx", "rt", "coverage"]),
    ]
)
