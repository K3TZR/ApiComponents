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
    // Api6000
    .target(name: "Api6000",dependencies: [
      .product(name: "LoginView", package: "ViewComponents"),
      .product(name: "LevelIndicatorView", package: "ViewComponents"),
      .product(name: "Shared", package: "UtilityComponents"),
      .product(name: "SecureStorage", package: "UtilityComponents"),
      .product(name: "JWTDecode", package: "JWTDecode.swift"),
      .product(name: "CocoaAsyncSocket", package: "CocoaAsyncSocket"),
      .product(name: "Vita", package: "UtilityComponents"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
        
    // ---------------- Tests ----------------
    // Api6000Tests
    .testTarget(name: "Api6000Tests",dependencies: ["Api6000"]),
  ]
)
