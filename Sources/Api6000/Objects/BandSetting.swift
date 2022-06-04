//
//  BandSetting.swift
//  Components6000/Radio/Objects
//
//  Created by Douglas Adams on 4/6/19.
//  Copyright © 2019 Douglas Adams. All rights reserved.
//

import Foundation

import Shared

// BandSetting Class implementation
//      creates a BandSetting instance to be used by a Client to support the
//      processing of the band settings. BandSetting structs are added, removed and
//      updated by the incoming TCP messages. They are collected in the
//      Model.bandSettings collection.

public struct BandSetting: Identifiable {
  // ------------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: BandId

  public var initialized: Bool {
    get { Model.q.sync { _initialized } }
    set { if newValue != _initialized { Model.q.sync(flags: .barrier) { _initialized = newValue } }}}
  public var accTxEnabled: Bool {
    get { Model.q.sync { _accTxEnabled } }
    set { if newValue != _accTxEnabled { Model.q.sync(flags: .barrier) { _accTxEnabled = newValue } }}}
  public var accTxReqEnabled: Bool {
    get { Model.q.sync { _accTxReqEnabled } }
    set { if newValue != _accTxReqEnabled { Model.q.sync(flags: .barrier) { _accTxReqEnabled = newValue } }}}
  public var bandName: String {
    get { Model.q.sync { _bandName } }
    set { if newValue != _bandName { Model.q.sync(flags: .barrier) { _bandName = newValue } }}}
  public var hwAlcEnabled: Bool {
    get { Model.q.sync { _hwAlcEnabled } }
    set { if newValue != _hwAlcEnabled { Model.q.sync(flags: .barrier) { _hwAlcEnabled = newValue } }}}
  public var inhibit: Bool {
    get { Model.q.sync { _inhibit } }
    set { if newValue != _inhibit { Model.q.sync(flags: .barrier) { _inhibit = newValue } }}}
  public var rcaTxReqEnabled: Bool {
    get { Model.q.sync { _rcaTxReqEnabled } }
    set { if newValue != _rcaTxReqEnabled { Model.q.sync(flags: .barrier) { _rcaTxReqEnabled = newValue } }}}
  public var rfPower: Int {
    get { Model.q.sync { _rfPower } }
    set { if newValue != _rfPower { Model.q.sync(flags: .barrier) { _rfPower = newValue } }}}
  public var tunePower: Int {
    get { Model.q.sync { _tunePower } }
    set { if newValue != _tunePower { Model.q.sync(flags: .barrier) { _tunePower = newValue } }}}
  public var tx1Enabled: Bool {
    get { Model.q.sync { _tx1Enabled } }
    set { if newValue != _tx1Enabled { Model.q.sync(flags: .barrier) { _tx1Enabled = newValue } }}}
  public var tx2Enabled: Bool {
    get { Model.q.sync { _tx2Enabled } }
    set { if newValue != _tx2Enabled { Model.q.sync(flags: .barrier) { _tx2Enabled = newValue } }}}
  public var tx3Enabled: Bool {
    get { Model.q.sync { _tx3Enabled } }
    set { if newValue != _tx3Enabled { Model.q.sync(flags: .barrier) { _tx3Enabled = newValue } }}}

  private var _initialized = false
  private var _accTxEnabled = false
  private var _accTxReqEnabled = false
  private var _bandName = ""
  private var _hwAlcEnabled = false
  private var _inhibit = false
  private var _rcaTxReqEnabled = false
  private var _rfPower = 0
  private var _tunePower = 0
  private var _tx1Enabled = false
  private var _tx2Enabled = false
  private var _tx3Enabled = false
  
  public enum BandSettingToken: String {
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
  
  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: BandId) { self.id = id }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Parse a BandSetting status message
  /// - Parameters:
  ///   - properties:     a KeyValuesArray of BandSetting properties
  ///   - inUse:          false = "to be deleted"
  public static func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id
    if let id = properties[0].key.objectId {
      // is the object in use?
      if inUse {
        // YES, does it exist?
        if Model.shared.bandSettings[id: id] == nil {
          // NO, create a new BandSetting & add it to the BandSettingCollection
          Model.shared.bandSettings[id: id] = BandSetting(id)
          log("BandSetting \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values to the BandSetting for parsing
        Model.shared.bandSettings[id: id]?.parseProperties(Array(properties.dropFirst(1)) )
      } else {
        // NO, does it exist?
        if Model.shared.bandSettings[id: id] != nil {
          // YES, remove it
          remove(id)
        }
      }
    }
  }
  
  public static func setProperty(radio: Radio, _ id: BandId, property: BandSettingToken, value: Any) {
    // FIXME: add commands
  }
  
//  public static func getProperty( _ id: BandId, property: BandSettingToken) -> Any? {
//    switch property {
//
//    case .accTxEnabled:     return Model.shared.bandSettings[id: id]!.accTxEnabled as Any
//    case .accTxReqEnabled:  return Model.shared.bandSettings[id: id]!.accTxReqEnabled as Any
//    case .bandName:         return Model.shared.bandSettings[id: id]!.bandName as Any
//    case .hwAlcEnabled:     return Model.shared.bandSettings[id: id]!.hwAlcEnabled as Any
//    case .inhibit:          return Model.shared.bandSettings[id: id]!.inhibit as Any
//    case .rcaTxReqEnabled:  return Model.shared.bandSettings[id: id]!.rcaTxReqEnabled as Any
//    case .rfPower:          return Model.shared.bandSettings[id: id]!.rfPower as Any
//    case .tunePower:        return Model.shared.bandSettings[id: id]!.tunePower as Any
//    case .tx1Enabled:       return Model.shared.bandSettings[id: id]!.tx1Enabled as Any
//    case .tx2Enabled:       return Model.shared.bandSettings[id: id]!.tx2Enabled as Any
//    case .tx3Enabled:       return Model.shared.bandSettings[id: id]!.tx3Enabled as Any
//    }
//  }
  
  /// Remove the specified BandSetting
  /// - Parameter id:     an AmplifierId
  public static func remove(_ id: BandId) {
    Model.shared.bandSettings.remove(id: id)
    log("BandSetting \(id.hex): removed", .debug, #function, #file, #line)
  }
  
  /// Remove all BandSettings
  public static func removeAll() {
    for bandSetting in Model.shared.bandSettings {
      remove(bandSetting.id)
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Parse BandSetting key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private mutating func parseProperties(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = BandSettingToken(rawValue: property.key) else {
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
  
  /// Send a command to Set a BandSetting property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified BandSetting
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: BandId, _ token: BandSettingToken, _ value: Any) {
    // FIXME: add commands
  }
}


