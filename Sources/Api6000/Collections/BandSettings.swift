//
//  BandSettings.swift
//  
//
//  Created by Douglas Adams on 6/11/22.
//

import Foundation
import IdentifiedCollections

import ApiShared

public actor BandSettings {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
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
  
  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _bandSettings = IdentifiedArrayOf<BandSetting>()
  
  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = BandSettings()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func add(_ bandSetting: BandSetting) {
    _bandSettings[id: bandSetting.id] = bandSetting
    updateModel()
  }
  
  public func exists(id: BandId) -> Bool {
    _bandSettings[id: id] != nil
  }
  
  /// Parse a BandSetting status message
  /// - Parameters:
  ///   - properties:     a KeyValuesArray of BandSetting properties
  ///   - inUse:          false = "to be deleted"
  public func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id
    if let id = properties[0].key.objectId {
      // is the object in use?
      if inUse {
        // YES, does it exist?
        if !exists(id: id) {
          // NO, create a new BandSetting
          add( BandSetting(id) )
          log("BandSetting \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values to the BandSetting for parsing
        parseProperties(id, Array(properties.dropFirst(1)) )
      } else {
        remove(id)
      }
    }
  }
  
  /// Remove a BandSetting
  /// - Parameter id:   a BandSetting Id
  public func remove(_ id: BandId)  {
    _bandSettings.remove(id: id)
    log("BandSetting \(id.hex): removed", .debug, #function, #file, #line)
    
    updateModel()
  }
  
  /// Remove all Tnfs
  public func removeAll()  {
    for bandSetting in _bandSettings {
      remove(bandSetting.id)
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Parse BandSetting key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private func parseProperties(_ id: BandId, _ properties: KeyValuesArray) {
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
        
      case .accTxEnabled:     _bandSettings[id: id]?.accTxEnabled = property.value.bValue
      case .accTxReqEnabled:  _bandSettings[id: id]?.accTxReqEnabled = property.value.bValue
      case .bandName:         _bandSettings[id: id]?.bandName = property.value
      case .hwAlcEnabled:     _bandSettings[id: id]?.hwAlcEnabled = property.value.bValue
      case .inhibit:          _bandSettings[id: id]?.inhibit = property.value.bValue
      case .rcaTxReqEnabled:  _bandSettings[id: id]?.rcaTxReqEnabled = property.value.bValue
      case .rfPower:          _bandSettings[id: id]?.rfPower = property.value.iValue
      case .tunePower:        _bandSettings[id: id]?.tunePower = property.value.iValue
      case .tx1Enabled:       _bandSettings[id: id]?.tx1Enabled = property.value.bValue
      case .tx2Enabled:       _bandSettings[id: id]?.tx2Enabled = property.value.bValue
      case .tx3Enabled:       _bandSettings[id: id]?.tx3Enabled = property.value.bValue
      }
      // is it initialized?
      if _bandSettings[id: id]?.initialized == false {
        // NO, it is now
        _bandSettings[id: id]?.initialized = true
        log("BandSetting \(id.hex): initialized", .debug, #function, #file, #line)
      }
    }
    updateModel()
  }
  
  private func updateModel() {
    Task {
      await Model.shared.setBandSettings(_bandSettings)
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         a BandSetting Id
  ///   - property:   a Tnf Token
  ///   - value:      the new value
  public static nonisolated func setProperty(radio: Radio, id: BandId, property: BandSettingToken, value: Any) {
    // FIXME: add commands
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Send a command to Set a Tnf property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Tnf
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: BandId, _ token: BandSettingToken, _ value: Any) {
    // FIXME: add commands
  }
}

// ----------------------------------------------------------------------------
// MARK: - BandSetting Struct

public struct BandSetting: Identifiable {
  // ------------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: BandId
  
  public var initialized = false
  public var accTxEnabled = false
  public var accTxReqEnabled = false
  public var bandName = ""
  public var hwAlcEnabled = false
  public var inhibit = false
  public var rcaTxReqEnabled = false
  public var rfPower = 0
  public var tunePower = 0
  public var tx1Enabled = false
  public var tx2Enabled = false
  public var tx3Enabled = false
  
  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: BandId) { self.id = id }
}
