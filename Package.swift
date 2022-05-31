// swift-tools-version:5.5
/*
 © Copyright 2018-2022, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

// NOTE: This won't work. It's here, just to give guidance on dependencies.

import PackageDescription

let package = Package(
    name: "AmbiaMara",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "AmbiaMara",
                 targets: ["AmbiaMara"]
        )],
    dependencies: [
        .package(name: "RVS_Generic_Swift_Toolbox",
                 url: "git@github.com:RiftValleySoftware/RVS_Generic_Swift_Toolbox.git",
                 from: "1.8.1"),
        .package(name: "RVS_BasicGCDTimer",
                 url: "git@github.com:RiftValleySoftware/RVS_BasicGCDTimer.git",
                 from: "1.5.0"),
        .package(name: "RVS_PersistentPrefs",
                 url: "git@github.com:RiftValleySoftware/RVS_PersistentPrefs.git",
                 from: "1.3.1"),
        .package(name: "RVS_RetroLEDDisplay",
                 url: "git@github.com:RiftValleySoftware/RVS_RetroLEDDisplay.git",
                 from: "1.4.1")
    ],
    targets: [
        .target(name: "AmbiaMara",
                dependencies: [
                    .product(name: "RVS_Generic_Swift_Toolbox",
                             package: "RVS_Generic_Swift_Toolbox"),
                    .product(name: "RVS_BasicGCDTimer",
                             package: "RVS_BasicGCDTimer"),
                    .product(name: "RVS_PersistentPrefs",
                             package: "RVS_PersistentPrefs"),
                    .product(name: "RVS_RetroLEDDisplay",
                             package: "RVS_RetroLEDDisplay")
                    ])
    ]
)
