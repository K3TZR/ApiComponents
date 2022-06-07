//
//  Xvtr.swift
//  Api6000Components/Api6000/Objects
//
//  Created by Douglas Adams on 6/24/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation

import Shared

// Xvtr Struct
//      creates an Xvtr instance to be used by a Client to support the
//      processing of an Xvtr. Xvtr structs are added, removed and updated by
//      the incoming TCP messages. They are collected in the Model.xvtrs
//      collection.

public struct Xvtr: Identifiable {
  // ----------------------------------------------------------------------------
  // MARK: - Published properties
  
  public internal(set) var id: XvtrId
  public internal(set) var initialized = false
  
  public internal(set) var isValid = false
  public internal(set) var preferred = false
  public internal(set) var twoMeterInt = 0
  public internal(set) var ifFrequency: Hz = 0
  public internal(set) var loError = 0
  public internal(set) var name = ""
  public internal(set) var maxPower = 0
  public internal(set) var order = 0
  public internal(set) var rfFrequency: Hz = 0
  public internal(set) var rxGain = 0
  public internal(set) var rxOnly = false
  
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
  // MARK: - Initialization
  
  public init(_ id: XvtrId) { self.id = id }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Parse an Xvtr status message
  /// - Parameters:
  ///   - keyValues:      a KeyValuesArray
  ///   - inUse:          false = "to be deleted"
  static func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true ) {
    // get the id
    if let id = properties[0].key.objectId {
      // isthe Xvtr in use?
      if inUse {
        // YES, does the object exist?
        if Model.shared.xvtrs[id: id] == nil {
          // NO, create a new Xvtr & add it to the Xvtrs collection
          Model.shared.xvtrs[id: id] = Xvtr(id)
          log("Xvtr \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values to the Xvtr for parsing
        Model.shared.xvtrs[id: id]?.parseProperties( Array(properties.dropFirst(1)) )
        
      } else {
        // does it exist?
        if Model.shared.xvtrs[id: id] != nil {
          // YES, remove it
          remove(id)
        }
      }
    }
  }
  
  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         a Tnf Id
  ///   - property:   a Tnf Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, _ id: XvtrId, token: XvtrToken, value: Any) {
    sendCommand(radio, id, token, value)
  }
  
  /// Remove an Xvtr
  /// - Parameter id:   a Xvtr Id
  public static func remove(_ id: XvtrId)  {
    Model.shared.xvtrs.remove(id: id)
    log("Xvtr \(id.hex): removed", .debug, #function, #file, #line)
  }
  
  /// Remove all Xvtrs
  public static func removeAll()  {
    for xvtr in Model.shared.xvtrs {
      remove(xvtr.id)
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Parse Xvtr key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private mutating func parseProperties(_ properties: KeyValuesArray) {
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
        
      case .name:         name = String(property.value.prefix(4))
      case .ifFrequency:  ifFrequency = property.value.mhzToHz
      case .isValid:      isValid = property.value.bValue
      case .loError:      loError = property.value.iValue
      case .maxPower:     maxPower = property.value.iValue
      case .order:        order = property.value.iValue
      case .preferred:    preferred = property.value.bValue
      case .rfFrequency:  rfFrequency = property.value.mhzToHz
      case .rxGain:       rxGain = property.value.iValue
      case .rxOnly:       rxOnly = property.value.bValue
      case .twoMeterInt:  twoMeterInt = property.value.iValue
      }
    }
    // is it initialized?
    if initialized == false {
      // NO, it is now
      initialized = true
      log("Xvtr \(id): initialized name = \(name)", .debug, #function, #file, #line)
    }
  }
  
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
