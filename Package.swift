// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "NativeDating",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "NativeDating",
            targets: ["NativeDating"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "NativeDating",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ],
            path: "NativeDating"
        )
    ]
)
