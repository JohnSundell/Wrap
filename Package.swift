// swift-tools-version:4.0

/**
 *  Wrap
 *  Copyright (c) John Sundell 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import PackageDescription

let package = Package(
    name: "Wrap",
    products: [
        .library(name: "Wrap", targets: ["Wrap"])
    ],
    targets: [
        .target(
            name: "Wrap",
            path: "Sources"
        ),
        .testTarget(
            name: "WrapTests",
            dependencies: ["Wrap"]
        )
    ]
)
