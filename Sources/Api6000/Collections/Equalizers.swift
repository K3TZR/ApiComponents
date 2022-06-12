//
//  Equalizers.swift
//  
//
//  Created by Douglas Adams on 6/11/22.
//

import Foundation
import IdentifiedCollections

import Shared

public actor Equalizers {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
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
  
  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _equalizers = IdentifiedArrayOf<Equalizer>()
  
  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = Equalizers()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func add(_ equalizer: Equalizer) {
    _equalizers[id: equalizer.id] = equalizer
    updateModel()
  }
  
  public func exists(id: EqualizerId) -> Bool {
    _equalizers[id: id] != nil
  }
  
  /// Parse an Equalizer status message
  /// - Parameters:
  ///   - properties:     a KeyValuesArray of Equalizer properties
  ///   - inUse:          false = "to be deleted"
  public func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id (only allow valid id's)
    let id = properties[0].key
    guard id == "rxsc" || id == "txsc" else { return }
    // is the object in use?
    if inUse {
      // YES, does it exist?
      if !exists(id: id) {
        // NO, create a new Equalizer & add it to the Equalizers collection
        add( Equalizer(id) )
        log("Equalizer \(id): added", .debug, #function, #file, #line)
      }
      // pass the remaining key values to the Equalizer for parsing
      parseProperties( id, Array(properties.dropFirst(1)) )
      
    } else {
      remove(id)
    }
  }
  
  /// Remove an Equalizer
  /// - Parameter id:   an Equalizer Id
  public func remove(_ id: EqualizerId)  {
    _equalizers.remove(id: id)
    log("Equalizer \(id): removed", .debug, #function, #file, #line)
    
    updateModel()
  }
  
  /// Remove all Equalizers
  public func removeAll()  {
    for equalizer in _equalizers {
      remove(equalizer.id)
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Parse Equalizer key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private func parseProperties(_ id: EqualizerId, _ properties: KeyValuesArray) {
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
        
      case .level63Hz:    _equalizers[id: id]?.level63Hz   = property.value.iValue
      case .level125Hz:   _equalizers[id: id]?.level125Hz  = property.value.iValue
      case .level250Hz:   _equalizers[id: id]?.level250Hz  = property.value.iValue
      case .level500Hz:   _equalizers[id: id]?.level500Hz  = property.value.iValue
      case .level1000Hz:  _equalizers[id: id]?.level1000Hz = property.value.iValue
      case .level2000Hz:  _equalizers[id: id]?.level2000Hz = property.value.iValue
      case .level4000Hz:  _equalizers[id: id]?.level4000Hz = property.value.iValue
      case .level8000Hz:  _equalizers[id: id]?.level8000Hz = property.value.iValue
      case .enabled:      _equalizers[id: id]?.eqEnabled   = property.value.bValue
      }
      // is it initialized?
      if _equalizers[id: id]?.initialized == false {
        // NO, it is now
        _equalizers[id: id]?.initialized = true
        log("Equalizer \(id): initialized", .debug, #function, #file, #line)
      }
    }
    updateModel()
  }
  
  private func updateModel() {
    Task {
      await Model.shared.setEqualizers(_equalizers)
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         an Equalizer Id
  ///   - property:   an Equalizer Token
  ///   - value:      the new value
  public static nonisolated func setProperty(radio: Radio, id: EqualizerId, property: EqualizerToken, value: Any) {
    sendCommand( radio, id, property, value)
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Send a command to Set a Equalizer property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Equalizer
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: EqualizerId, _ token: EqualizerToken, _ value: Any) {
    radio.send("equalizer set " + "\(id) " + token.rawValue + "=\(value)")
  }
}

// ----------------------------------------------------------------------------
// MARK: - Equalizer Struct

public struct Equalizer: Identifiable {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: EqualizerId
  
  public var initialized = false
  public var eqEnabled = false
  public var level63Hz = 0
  public var level125Hz = 0
  public var level250Hz = 0
  public var level500Hz = 0
  public var level1000Hz = 0
  public var level2000Hz = 0
  public var level4000Hz = 0
  public var level8000Hz = 0
  
  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: EqualizerId) { self.id = id }
}
