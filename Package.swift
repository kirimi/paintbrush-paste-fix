// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PaintbrushPasteFix",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "PaintbrushPasteFix", targets: ["PaintbrushPasteFix"])
    ],
    targets: [
        .target(name: "PasteFixCore"),
        .executableTarget(
            name: "PaintbrushPasteFix",
            dependencies: ["PasteFixCore"],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        ),
        .testTarget(
            name: "PasteFixCoreTests",
            dependencies: ["PasteFixCore"]
        )
    ]
)
