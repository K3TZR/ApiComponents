//
//  Equalizer.swift
//  Api6000Components/Api6000/Objects
//
//  Created by Douglas Adams on 5/31/15.
//  Copyright (c) 2015 Douglas Adams, K3TZR
//

import Foundation

import Shared

// Equalizer Struct
//      creates an Equalizer instance to be used by a Client to support the
//      rendering of an Equalizer. Equalizer structs are added, removed and
//      updated by the incoming TCP messages. They are collected in the
//      EqualizerCollection.

public struct Equalizer: Identifiable {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties

  public internal(set) var id: EqualizerId
  public internal(set) var initialized = false

  public var eqEnabled = false
  public var level63Hz = 0
  public var level125Hz = 0
  public var level250Hz = 0
  public var level500Hz = 0
  public var level1000Hz = 0
  public var level2000Hz = 0
  public var level4000Hz = 0
  public var level8000Hz = 0

  public enum EqualizerToken: String {
    case level63Hz   = "63hz"
    case level125Hz  = "125hz"
    case level250Hz  = "250hz"
    case level500Hz  = "500hz"
    case level1000Hz = "1000hz"
    case level2000Hz = "2000hz"
    case level4000Hz = "4000hz"
    case level8000Hz = "8000hz"
    case enabled     = "mode"
  }

  // ------------------------------------------------------------------------------
  // MARK: - Initialization

  public init(_ id: EqualizerId) { self.id = id }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Static properties

  // Equality
//  public static func == (lhs: Equalizer, rhs: Equalizer) -> Bool {
//    lhs.id == rhs.id
//  }
  
  /// Parse an Equalizer status message
  /// - Parameters:
  ///   - properties:     a KeyValuesArray of Equalizer properties
  ///   - inUse:          false = "to be deleted"
  public static func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id (only allow valid id's)
    let id = properties[0].key
    guard id == "rxsc" || id == "txsc" else { return }
    // is the object in use?
    if inUse {
      // YES, does it exist?
      if Model.shared.equalizers[id: id] == nil {
        // NO, create a new Equalizer & add it to the Equalizers collection
        Model.shared.equalizers[id: id] = Equalizer(id)
        log("Equalizer \(id): added", .debug, #function, #file, #line)
      }
      // pass the remaining key values to the Equalizer for parsing
      Model.shared.equalizers[id: id]?.parseProperties( Array(properties.dropFirst(1)) )
    
    } else {
      if Model.shared.equalizers[id: id] != nil {
        remove(id)
      }
    }
  }
    
  public static func setProperty(radio: Radio, _ id: EqualizerId, property: EqualizerToken, value: Any) {
    // FIXME: add commands
  }

//  public static func getProperty( _ id: EqualizerId, property: EqualizerToken) -> Any? {
//    switch property {
//      
//    case .level63Hz:    return Model.shared.equalizers[id: id]!.level63Hz as Any
//    case .level125Hz:   return Model.shared.equalizers[id: id]!.level125Hz as Any
//    case .level250Hz:   return Model.shared.equalizers[id: id]!.level250Hz as Any
//    case .level500Hz:   return Model.shared.equalizers[id: id]!.level500Hz as Any
//    case .level1000Hz:  return Model.shared.equalizers[id: id]!.level1000Hz as Any
//    case .level2000Hz:  return Model.shared.equalizers[id: id]!.level2000Hz as Any
//    case .level4000Hz:  return Model.shared.equalizers[id: id]!.level4000Hz as Any
//    case .level8000Hz:  return Model.shared.equalizers[id: id]!.level8000Hz as Any
//    case .enabled:      return Model.shared.equalizers[id: id]!.eqEnabled as Any
//    }
//  }

  /// Remove the specified Equalizer
  /// - Parameter id:     an EqualizerId
  public static func remove(_ id: EqualizerId) {
    Model.shared.equalizers.remove(id: id)
    log("Equalizer \(id): removed", .debug, #function, #file, #line)
  }
  
   /// Remove all Equalizers
  public static func removeAll() {
     for equalizer in Model.shared.equalizers {
       remove(equalizer.id)
     }
   }

  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Parse Equalizer key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private mutating func parseProperties(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = EqualizerToken(rawValue: property.key) else {
        // log it and ignore the Key
        log("Equalizer \(id) unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // known keys
      switch token {
        
      case .level63Hz:    level63Hz = property.value.iValue
      case .level125Hz:   level125Hz = property.value.iValue
      case .level250Hz:   level250Hz = property.value.iValue
      case .level500Hz:   level500Hz = property.value.iValue
      case .level1000Hz:  level1000Hz = property.value.iValue
      case .level2000Hz:  level2000Hz = property.value.iValue
      case .level4000Hz:  level4000Hz = property.value.iValue
      case .level8000Hz:  level8000Hz = property.value.iValue
      case .enabled:      eqEnabled = property.value.bValue
      }
      // is it initialized?
      if initialized == false {
        // NO, it is now
        initialized = true
        log("Equalizer \(id): initialized", .debug, #function, #file, #line)
      }
    }
  }
  
  /// Send a command to Set a Equalizer property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Equalizer
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: EqualizerId, _ token: EqualizerToken, _ value: Any) {
    // FIXME: add commands
  }
}
