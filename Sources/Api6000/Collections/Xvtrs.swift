//
//  Xvtrs.swift
//  
//
//  Created by Douglas Adams on 6/11/22.
//

import Foundation
import IdentifiedCollections

import ApiShared

public actor Xvtrs {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public enum XvtrToken: String {
    case name
    case ifFrequency    = "if_freq"
    case isValid        = "is_valid"
    case loError        = "lo_error"
    case maxPower       = "max_power"
    case order
    case preferred
    case rfFrequency    = "rf_freq"
    case rxGain         = "rx_gain"
    case rxOnly         = "rx_only"
    case twoMeterInt    = "two_meter_int"
  }
  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _xvtrs = IdentifiedArrayOf<Xvtr>()
  
  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = Xvtrs()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func add(_ xvtr: Xvtr) {
    _xvtrs[id: xvtr.id] = xvtr
    updateModel()
  }
  
  public func exists(id: XvtrId) -> Bool {
    _xvtrs[id: id] != nil
  }
  
  /// Parse an Xvtr status message
  /// - Parameters:
  ///   - keyValues:      a KeyValuesArray
  ///   - inUse:          false = "to be deleted"
  public func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true ) {
    // get the id
    if let id = properties[0].key.objectId {
      // isthe Xvtr in use?
      if inUse {
        // YES, does the object exist?
        if !exists(id: id) {
          // NO, create a new Xvtr & add it to the Xvtrs collection
          add( Xvtr(id) )
          log("Xvtr \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values to the Xvtr for parsing
        parseProperties( id, Array(properties.dropFirst(1)) )
        
      } else {
        remove(id)
      }
    }
  }
  /// Remove a Xvtr
  /// - Parameter id:   a Xvtr Id
  public func remove(_ id: XvtrId)  {
    _xvtrs.remove(id: id)
    log("Xvtr \(id.hex): removed", .debug, #function, #file, #line)

    updateModel()
  }
  
  /// Remove all Xvtrs
  public func removeAll()  {
    for xvtr in _xvtrs {
      remove(xvtr.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Parse Xvtr key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private func parseProperties(_ id: XvtrId, _ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = XvtrToken(rawValue: property.key) else {
        // log it and ignore the Key
        log("Xvtr, unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // Known keys, in alphabetical order
      switch token {
        
      case .name:         _xvtrs[id: id]?.name = String(property.value.prefix(4))
      case .ifFrequency:  _xvtrs[id: id]?.ifFrequency = property.value.mhzToHz
      case .isValid:      _xvtrs[id: id]?.isValid = property.value.bValue
      case .loError:      _xvtrs[id: id]?.loError = property.value.iValue
      case .maxPower:     _xvtrs[id: id]?.maxPower = property.value.iValue
      case .order:        _xvtrs[id: id]?.order = property.value.iValue
      case .preferred:    _xvtrs[id: id]?.preferred = property.value.bValue
      case .rfFrequency:  _xvtrs[id: id]?.rfFrequency = property.value.mhzToHz
      case .rxGain:       _xvtrs[id: id]?.rxGain = property.value.iValue
      case .rxOnly:       _xvtrs[id: id]?.rxOnly = property.value.bValue
      case .twoMeterInt:  _xvtrs[id: id]?.twoMeterInt = property.value.iValue
      }
    }
    // is it initialized?
    if _xvtrs[id: id]?.initialized == false {
      // NO, it is now
      _xvtrs[id: id]?.initialized = true
      log("Xvtr \(id): initialized name = \(_xvtrs[id: id]?.name ?? "")", .debug, #function, #file, #line)
    }
    updateModel()
  }

  private func updateModel() {
    Task {
      await Model.shared.setXvtrs(_xvtrs)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         a Xvtr Id
  ///   - property:   a Xvtr Token
  ///   - value:      the new value
  public static nonisolated func setProperty(radio: Radio, _ id: XvtrId, token: XvtrToken, value: Any) {
    sendCommand(radio, id, token, value)
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  
  /// Send a command to Set an Xvtr property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Xvtr
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: XvtrId, _ token: XvtrToken, _ value: Any) {
    radio.send("xvtr set " + "\(id) " + token.rawValue + "=\(value)")
  }
}

// ----------------------------------------------------------------------------
// MARK: - Xvtr STruct

public struct Xvtr: Identifiable {
  // ----------------------------------------------------------------------------
  // MARK: - Published properties
  
  public let id: XvtrId
  
  public var initialized = false
  public var isValid = false
  public var preferred = false
  public var twoMeterInt = 0
  public var ifFrequency: Hz = 0
  public var loError = 0
  public var name = ""
  public var maxPower = 0
  public var order = 0
  public var rfFrequency: Hz = 0
  public var rxGain = 0
  public var rxOnly = false
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: XvtrId) { self.id = id }
}
