// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ApiComponents",
  platforms: [
    .iOS(.v15),
    .macOS(.v12),
  ],
  products: [
    .library(name: "Api6000", targets: ["Api6000"]),
    .library(name: "TcpCommands", targets: ["TcpCommands"]),
    .library(name: "UdpStreams", targets: ["UdpStreams"]),
    .library(name: "ApiShared", targets: ["ApiShared"]),
    .library(name: "ApiVita", targets: ["ApiVita"]),
  ],
  dependencies: [
    .package(url: "https://github.com/robbiehanson/CocoaAsyncSocket", from: "7.6.5"),
    .package(url: "https://github.com/K3TZR/UtilityComponents.git", branch: "main"),
    .package(url: "https://github.com/K3TZR/ViewComponents.git", branch: "main"),
    .package(url: "https://github.com/auth0/JWTDecode.swift", from: "2.6.0"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.32.0"),
  ],
  targets: [
    // --------------- Modules ---------------
    // Shared
    .target(name: "ApiShared",dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),

    // Vita
    .target(name: "ApiVita",dependencies: [
    ]),

    // Api6000
    .target(name: "Api6000",dependencies: [
      "TcpCommands",
      "UdpStreams",
      .product(name: "LoginView", package: "ViewComponents"),
      .product(name: "SecureStorage", package: "UtilityComponents"),
      .product(name: "JWTDecode", package: "JWTDecode.swift"),
      .product(name: "CocoaAsyncSocket", package: "CocoaAsyncSocket"),
//      "LanDiscovery",
//      "WanDiscovery",
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),

    // LanDiscovery
//    .target(name: "LanDiscovery",dependencies: [
//      .product(name: "Shared", package: "UtilityComponents"),
//      .product(name: "Vita", package: "UtilityComponents"),
//      .product(name: "CocoaAsyncSocket", package: "CocoaAsyncSocket"),
//    ]),
    
    // TcpCommands
    .target(name: "TcpCommands",dependencies: [
      "ApiShared",
//      .product(name: "Shared", package: "UtilityComponents"),
      .product(name: "CocoaAsyncSocket", package: "CocoaAsyncSocket"),
    ]),
    
    // UdpStreams
    .target(name: "UdpStreams",dependencies: [
      "ApiShared",
      "ApiVita",
//      .product(name: "Shared", package: "UtilityComponents"),
      .product(name: "CocoaAsyncSocket", package: "CocoaAsyncSocket"),
//      .product(name: "Vita", package: "UtilityComponents"),
    ]),

    // WanDiscovery
//    .target(name: "WanDiscovery",dependencies: [
//      .product(name: "Shared", package: "UtilityComponents"),
//      .product(name: "LoginView", package: "ViewComponents"),
//      .product(name: "SecureStorage", package: "UtilityComponents"),
//      .product(name: "JWTDecode", package: "JWTDecode.swift"),
//      .product(name: "CocoaAsyncSocket", package: "CocoaAsyncSocket"),
//    ]),
    
    // ---------------- Tests ----------------
    // Api6000Tests
    .testTarget(name: "Api6000Tests",dependencies: ["Api6000"]),

    // LanDiscoveryTests
//    .testTarget(name: "LanDiscoveryTests",dependencies: ["LanDiscovery"]),

    // TcpCommandsTests
    .testTarget(name: "TcpCommandsTests",dependencies: ["TcpCommands"]),

    // UdpStreamsTests
    .testTarget(name: "UdpStreamsTests",dependencies: ["UdpStreams"]),

    // WanDiscoveryTests
//    .testTarget(name: "WanDiscoveryTests",dependencies: ["WanDiscovery"]),
  ]
)
