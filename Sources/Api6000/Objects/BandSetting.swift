//
//  BandSetting.swift
//  Api6000Components/Api6000/Objects
//
//  Created by Douglas Adams on 4/6/19.
//  Copyright © 2019 Douglas Adams. All rights reserved.
//

import Foundation

import Shared

// BandSetting
//      creates a BandSetting instance to be used by a Client to support the
//      processing of the band settings. BandSetting instances are added, removed and
//      updated by the incoming TCP messages. They are collected in the
//      Model.bandSettings collection.
@MainActor
public class BandSetting: Identifiable, Equatable, ObservableObject {
  // Equality
  public nonisolated static func == (lhs: BandSetting, rhs: BandSetting) -> Bool {
    lhs.id == rhs.id
  }

  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: BandId) { self.id = id }
  
  // ------------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: BandId
  public var initialized: Bool = false

  @Published public var accTxEnabled: Bool = false
  @Published public var accTxReqEnabled: Bool = false
  @Published public var bandName: String = ""
  @Published public var hwAlcEnabled: Bool = false
  @Published public var inhibit: Bool = false
  @Published public var rcaTxReqEnabled: Bool = false
  @Published public var rfPower: Int = 0
  @Published public var tunePower: Int = 0
  @Published public var tx1Enabled: Bool = false
  @Published public var tx2Enabled: Bool = false
  @Published public var tx3Enabled: Bool  = false
  
  public enum Property: String {
    case accTxEnabled       = "acc_tx_enabled"
    case accTxReqEnabled    = "acc_txreq_enable"
    case bandName           = "band_name"
    case hwAlcEnabled       = "hwalc_enabled"
    case inhibit
    case rcaTxReqEnabled    = "rca_txreq_enable"
    case rfPower            = "rfpower"
    case tunePower          = "tunepower"
    case tx1Enabled         = "tx1_enabled"
    case tx2Enabled         = "tx2_enabled"
    case tx3Enabled         = "tx3_enabled"
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Instance methods
  
  /// Parse BandSetting key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) async {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = Property(rawValue: property.key) else {
        // log it and ignore the Key
        log("BandSetting \(id) unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // known keys
      switch token {
        
      case .accTxEnabled:     accTxEnabled = property.value.bValue
      case .accTxReqEnabled:  accTxReqEnabled = property.value.bValue
      case .bandName:         bandName = property.value
      case .hwAlcEnabled:     hwAlcEnabled = property.value.bValue
      case .inhibit:          inhibit = property.value.bValue
      case .rcaTxReqEnabled:  rcaTxReqEnabled = property.value.bValue
      case .rfPower:          rfPower = property.value.iValue
      case .tunePower:        tunePower = property.value.iValue
      case .tx1Enabled:       tx1Enabled = property.value.bValue
      case .tx2Enabled:       tx2Enabled = property.value.bValue
      case .tx3Enabled:       tx3Enabled = property.value.bValue
      }
      // is it initialized?
      if initialized == false {
        // NO, it is now
        initialized = true
        log("BandSetting \(id.hex): initialized", .debug, #function, #file, #line)
      }
    }
  }
}
