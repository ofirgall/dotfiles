// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "aerospace-switcher",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "aerospace-switcher",
            path: "Sources",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("QuartzCore"),
            ]
        )
    ]
)
