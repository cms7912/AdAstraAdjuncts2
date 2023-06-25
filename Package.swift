// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdAstraAdjuncts2",
    platforms: [
      .macOS(.v12)
//                , .iOS(15)
               ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AdAstra_Extensions2",
//            platforms: [.macOS(11), .iOS(15)],
            targets: ["AdAstra_Extensions2"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AdAstra_Extensions2"),
    ]
)
