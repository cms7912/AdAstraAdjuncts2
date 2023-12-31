// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package( // "The configuration of a Swift package."
  
  name: "AdAstraAdjuncts2",
  platforms: [
    .macOS(.v12)
    , .iOS(.v15)
  ],
  products: [ // "A package product defines an externally visible build artifact (library, executable, or plugin) that’s available to clients of a package."
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "AdAstraExtensions",
      //            platforms: [.macOS(11), .iOS(15)],
      targets: ["AdAstraExtensions"]
    ),
    
    //AdAstra DB Stack:
    .library( name: "AdAstraDBStackCore", targets: ["AdAstraDBStackCore"] ),
    
      .library( name: "AdAstraDBStackUI", targets: ["AdAstraDBStackUI"] ),
    
      .library( name: "AdAstraDBStackImportExport", targets: ["AdAstraDBStackImportExport"] ),
    
    
    //Sources/:
    .library( name: "AALogger", targets: ["AALogger"] ),
    .library( name: "AAQuantumValue", targets: ["AAQuantumValue"] ),
    .library( name: "AAUserInterface", targets: ["AAUserInterface"] ),
    .library( name: "AdAstra_Multiplatform", targets: ["AdAstra_Multiplatform"] ),
    .library( name: "AdAstraBridgingByShim", targets: ["AdAstraBridgingByShim"] ),
    .library( name: "UINSKit", targets: ["AdAstraBridgingByShim"] ),
    .library( name: "AdAstraBridgingNSExtensions", targets: ["AdAstraBridgingNSExtensions"] ),
    .library( name: "AdAstra_KangarooScrollView", targets: ["AdAstra_KangarooScrollView"] ),
    
//      .library( name: "AdAstraHotReloading", targets: ["AdAstraHotReloading"] ),
            ]
  
  , dependencies: [
    .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols", from: .init(4, 0, 0)),
    
      .package(url: "https://github.com/marmelroy/Zip.git", .upToNextMajor(from: "2.1.1")),
    
//      .package(url: "https://github.com/johnno1962/HotReloading", .upToNextMajor(from: .init(4, 0, 0))),
  ]
  
  , targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    // "Each target contains a set of source files that Swift Package Manager compiles into a module or test suite. You can vend targets to other packages by defining products that include the targets.
    //  A target may depend on other targets within the same package and on products vended by the package’s dependencies.
    
    .target(
      name: "AdAstraExtensions"
      , path: "AdAstraExtensions2"
    )
    
    , .target(
      // , .executableTarget(
      name: "AdAstraDBStackCore",
      dependencies:[
        "AdAstraExtensions",
        "AALogger",
        "AAFileManager"
        //                    "AdAstraBridgingByShim",
        //                    "AdAstraMockCoreData",
        //                    "SFSafeSymbols",
      ]
      , path: "AdAstraDBStack2/Core"
      // , exclude:["Resources"]
      , resources: [.process("Resources")] // <- `copy` or `process` 
      // , resources: [.copy("Resources")] // <- `copy` or `process`
      // , swiftSettings: [SwiftSetting.unsafeFlags(["CODE_SIGN_STYLE=Manual"])]
      // , swiftSettings: [SwiftSetting.unsafeFlags(["CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM="])]
      // , swiftSettings: [SwiftSetting.define("CODE_SIGN_STYLE=Manual")]
      // , swiftSettings: [SwiftSetting.define("CODE_SIGNING_ALLOWED=NO, CODE_SIGNING_REQUIRED=NO")]
      // https://stackoverflow.com/questions/63237395/generating-resource-bundle-accessor-type-bundle-has-no-member-module
      // related: https://forums.swift.org/t/xcode-14-beta-code-signing-issues-when-swiftpm-targets-include-resources/59685/4?page=2
      // with a 'Resources' folder in a package the code signing fails. So '.process' is needed, not '.copy'
    )
    
    
    , .target(
      // , .executableTarget(
      name: "AdAstraDBStackUI",
      dependencies:[
        "AdAstraExtensions",
        "AdAstraDBStackCore",
        "AdAstraBridgingByShim",
        //                    "AdAstraMockCoreData",
        "SFSafeSymbols",
        "AdAstra_Addons"
      ]
      , path: "AdAstraDBStack2/UI"
      //               , resources: [.copy("Resources")] // <- `copy` or `process` doesn't really matter
    )
    
    
    , .target(
      // , .executableTarget(
      name: "AdAstraDBStackImportExport",
      dependencies:[
        "AdAstraExtensions",
        "AdAstraDBStackCore",
        "AAFileManager",
        //                .package(url: "https://github.com/marmelroy/Zip.git", .upToNextMajor(from: "2.1.1")),
        "Zip"
        //                    "AdAstraBridgingByShim",
        //                    "AdAstraMockCoreData",
        //                    "SFSafeSymbols",
      ]
      , path: "AdAstraDBStack2/ImportExport"
      //               , resources: [.copy("Resources")] // <- `copy` or `process` doesn't really matter
    )
    
    
    // Sources/
    , .target( name: "AAFileManager", dependencies:[ "AdAstraExtensions", "AALogger", ] , path: "Sources/AAFileManager" )
    , .target( name: "AALogger", dependencies:[ "AdAstraExtensions", ] , path: "Sources/AALogger" )
    , .target( name: "AAQuantumValue", dependencies:[ "AdAstraExtensions", "AALogger" ] , path: "Sources/AAQuantumValue" )
    , .target( name: "AAUserInterface", dependencies:[ "AdAstraExtensions", "AALogger" ] , path: "Sources/AAUserInterface" )
    
    
    , .target( name: "AdAstra_Addons", dependencies:[ "AdAstraExtensions", "AALogger", "AdAstraBridgingNSExtensions"] , path: "Sources/AdAstra_Addons" )
    
,
  .target( name: "AdAstra_KangarooScrollView", dependencies:[
    "AdAstraExtensions",
    "AdAstra_Addons",
  "AALogger",
  // "AdAstraBridgingNSExtensions"
  ], path: "Sources/AdAstra_KangarooScrollView" )
    
    , .target( name: "AdAstra_Multiplatform", dependencies:[ "AdAstraExtensions", ] , path: "Sources/AdAstra_Multiplatform" )
    , .target( name: "AdAstraBridgingByMask", dependencies:[ "AdAstraExtensions",] , path: "Sources/AdAstra_MultiplatformBridgingByMask" )
    , .target( name: "AdAstraBridgingByShim", dependencies:[ "AdAstraExtensions" ] , path: "Sources/AdAstra_MultiplatformBridgingByShim" )
    , .target( name: "AdAstraBridgingNSExtensions", dependencies:[ "AdAstraExtensions", "AdAstraBridgingByMask", "AdAstraBridgingByShim"] , path: "Sources/AdAstra_MultiplatformBridgingNSExtensions" )
    
//    , .target( name: "AdAstraHotReloading", dependencies:["HotReloading"] , path: "Sources/AdAstra_HotReloading" )
    
  ]
)
