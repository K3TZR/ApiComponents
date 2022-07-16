//
//  Equalizer.swift
//  Api6000Components/Api6000/Objects
//
//  Created by Douglas Adams on 5/31/15.
//  Copyright (c) 2015 Douglas Adams, K3TZR
//

import Foundation

import Shared

// Equalizer
//      creates an Equalizer instance to be used by a Client to support the
//      rendering of an Equalizer. Equalizer instances are added, removed and
//      updated by the incoming TCP messages. They are collected in the
//      Model.equalizers collection.
@MainActor
public class Equalizer: Identifiable, Equatable, ObservableObject {
  // Equality
  public nonisolated static func == (lhs: Equalizer, rhs: Equalizer) -> Bool {
    lhs.id == rhs.id
  }

  // ------------------------------------------------------------------------------
  // MARK: - Initialization

  public init(_ id: EqualizerId) { self.id = id }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties

  public let id: EqualizerId
  public var initialized = false

  @Published public var eqEnabled = false
  @Published public var level63Hz: Double = 0
  @Published public var level125Hz: Double = 0
  @Published public var level250Hz: Double = 0
  @Published public var level500Hz: Double = 0
  @Published public var level1000Hz: Double = 0
  @Published public var level2000Hz: Double = 0
  @Published public var level4000Hz: Double = 0
  @Published public var level8000Hz: Double = 0

  public enum Property: String {
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
  // MARK: - Public Instance methods
  
  /// Parse key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) async {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = Property(rawValue: property.key) else {
        // log it and ignore the Key
        log("Equalizer \(id) unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // known keys
      switch token {

      case .level63Hz:    level63Hz = property.value.dValue
      case .level125Hz:   level125Hz = property.value.dValue
      case .level250Hz:   level250Hz = property.value.dValue
      case .level500Hz:   level500Hz = property.value.dValue
      case .level1000Hz:  level1000Hz = property.value.dValue
      case .level2000Hz:  level2000Hz = property.value.dValue
      case .level4000Hz:  level4000Hz = property.value.dValue
      case .level8000Hz:  level8000Hz = property.value.dValue
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


  
  
  
  
  
  
  
  
  public static func setEqualizerProperty(radio: Radio, id: EqualizerId, property: Property, value: Any) {
    switch property {
      
    case .level63Hz:    sendCommand(radio, id, "63Hz", value)
    case .level125Hz:   sendCommand(radio, id, "125Hz", value)
    case .level250Hz:   sendCommand(radio, id, "250Hz", value)
    case .level500Hz:   sendCommand(radio, id, "500Hz", value)
    case .level1000Hz:  sendCommand(radio, id, "1000Hz", value)
    case .level2000Hz:  sendCommand(radio, id, "2000Hz", value)
    case .level4000Hz:  sendCommand(radio, id, "4000Hz", value)
    case .level8000Hz:  sendCommand(radio, id, "8000Hz", value)
    case .enabled:      sendCommand(radio, id, .enabled, value)
    }
  }
  
  /// Send a command to Set a Equalizer property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Equalizer
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: EqualizerId, _ token: Property, _ value: Any) {
    radio.send("eq " + id + " " + token.rawValue + "=\(value)")
  }

  /// Send a command to Set a Equalizer property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Equalizer
  ///   - token:      a String value
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: EqualizerId, _ token: String, _ value: Any) {
    radio.send("eq " + id + " " + token + "=\(value)")

    print("-----> ", "eq " + id + " " + token + "=\(value)")
  }
}
