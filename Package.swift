// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(name: "StepSlider",
                      platforms: [
                        .macOS(.v11), .iOS(.v14)
                      ],
                      products: [
                        .library(name: "StepSlider",
                                 targets: ["StepSlider"])
                      ],
                      targets: [
                        .target(name: "StepSlider",
                                dependencies: []),
                        .testTarget(name: "StepSliderTests",
                                    dependencies: ["StepSlider"])
                      ])
