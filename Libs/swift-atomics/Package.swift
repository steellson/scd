// swift-tools-version:5.10
//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2020 - 2025 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import PackageDescription

var _cSettings: [CSetting] = []
var _swiftSettings: [SwiftSetting] = []

// Enable the use of native Swift compiler builtins instead of C atomics.
_cSettings += [
]
_swiftSettings += [
  .enableExperimentalFeature("BuiltinModule")
]

let package = Package(
  name: "swift-atomics",
  products: [
    .library(
      name: "Atomics",
      targets: ["Atomics"]),
  ],
  targets: [
    .target(
      name: "_AtomicsShims",
      exclude: [
        "CMakeLists.txt"
      ]
    ),
    .target(
      name: "Atomics",
      dependencies: ["_AtomicsShims"],
      exclude: [
        "CMakeLists.txt",
        "Conformances/AtomicBool.swift.gyb",
        "Conformances/IntegerConformances.swift.gyb",
        "Conformances/PointerConformances.swift.gyb",
        "Primitives/Primitives.native.swift.gyb",
        "Types/IntegerOperations.swift.gyb",
      ],
      cSettings: _cSettings,
      swiftSettings: _swiftSettings
    )
  ]
)
