// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "ClipStash",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "ClipStash",
            path: "Sources/ClipStash",
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ],
            linkerSettings: [
                .linkedLibrary("sqlite3"),
            ]
        ),
    ]
)
