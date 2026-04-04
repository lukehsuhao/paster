// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Paster",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/Kentzo/ShortcutRecorder.git", from: "3.4.0"),
    ],
    targets: [
        .executableTarget(
            name: "Paster",
            dependencies: ["ShortcutRecorder"],
            path: "Sources/Paster",
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ],
            linkerSettings: [
                .linkedLibrary("sqlite3"),
            ]
        ),
    ]
)
