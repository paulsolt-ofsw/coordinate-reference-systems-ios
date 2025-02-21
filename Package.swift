// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "crs", // Name of your project/package
    platforms: [
        .iOS(.v12),
        ], 
    products: [
        .library(
            name: "crs", // Name crs, instead of crs-ios because of umbrella header issue
            targets: ["crs"]), // Targets included in the library
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "crs",
            dependencies: [
            ],
            path: "crs-ios",
            exclude: [
                "crs_ios.swift", // Only Objc or Swift is allowed, this file does nothing
                ],
            publicHeadersPath: "",
            cSettings: [
                .headerSearchPath("bound"),
                .headerSearchPath("common"),
                .headerSearchPath("derived"),
                .headerSearchPath("engineering"),
                .headerSearchPath("geo"),
                .headerSearchPath("metadata"),
                .headerSearchPath("operation"),
                .headerSearchPath("parametric"),
                .headerSearchPath("projected"),
                .headerSearchPath("temporal"),
                .headerSearchPath("util/proj"),
                .headerSearchPath("vertical"),
                .headerSearchPath("wkt")
            ]
            ),
            
        .testTarget(
            name: "crsTests",
            dependencies: [
                "crs",
                ],
            path: "crs-iosTests",
            exclude: [
                "CRSSwiftReadmeTest.swift",
            ],
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath("common"),
                .headerSearchPath("util/proj"),
                .headerSearchPath("wkt"),

                // We need to also search the target paths to build and run the unit tests
                .headerSearchPath("../crs-ios"),
                .headerSearchPath("../crs-ios/bound"),
                .headerSearchPath("../crs-ios/common"),
                .headerSearchPath("../crs-ios/derived"),
                .headerSearchPath("../crs-ios/engineering"),
                .headerSearchPath("../crs-ios/geo"),
                .headerSearchPath("../crs-ios/metadata"),
                .headerSearchPath("../crs-ios/operation"),
                .headerSearchPath("../crs-ios/parametric"),
                .headerSearchPath("../crs-ios/projected"),
                .headerSearchPath("../crs-ios/temporal"),
                .headerSearchPath("../crs-ios/util/proj"),
                .headerSearchPath("../crs-ios/vertical"),
                .headerSearchPath("../crs-ios/wkt")
            ]
            ), // Test target depends on the main target
    ]
)
