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
                 from: "1.7.2"),
        .package(name: "RVS_BasicGCDTimer",
                 url: "git@github.com:RiftValleySoftware/RVS_BasicGCDTimer.git",
                 from: "1.4.2"),
        .package(name: "RVS_PersistentPrefs",
                 url: "git@github.com:RiftValleySoftware/RVS_PersistentPrefs.git",
                 from: "1.2.8"),
        .package(name: "RVS_RetroLEDDisplay",
                 url: "git@github.com:RiftValleySoftware/RVS_RetroLEDDisplay.git",
                 from: "1.2.0")
    ],
    targets: [
        .target(name: "AmbiaMara",
                dependencies: [
                    .product(name: "RVS-Generic-Swift-Toolbox",
                             package: "RVS_Generic_Swift_Toolbox"),
                    .product(name: "RVS-BasicGCDTimer",
                             package: "RVS_BasicGCDTimer"),
                    .product(name: "RVS-Persistent-Prefs",
                             package: "RVS_PersistentPrefs"),
                    .product(name: "RVS-RetroLEDDisplay",
                             package: "RVS_RetroLEDDisplay"),
                    ])
    ]
)
