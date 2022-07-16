//
//  Tnf.swift
//  Api6000Components/Api6000/Objects
//
//  Created by Douglas Adams on 6/30/15.
//  Copyright © 2015 Douglas Adams. All rights reserved.
//

import Foundation

import Shared

// Tnf
//       creates a Tnf instance to be used by a Client to support the
//       rendering of a Tnf. Tnf instances are added, removed and
//       updated by the incoming TCP messages. They are collected in the
//       Model.tnfs collection.
@MainActor
public class Tnf: Identifiable, Equatable, ObservableObject {
  // Equality
  public nonisolated static func == (lhs: Tnf, rhs: Tnf) -> Bool {
    lhs.id == rhs.id
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization

  public init(_ id: TnfId) { self.id = id }

  // ----------------------------------------------------------------------------
  // MARK: - Public properties

  public let id: TnfId
  public var initialized = false
  
  @Published public var depth: UInt = 0
  @Published public var frequency: Hz = 0
  @Published public var permanent = false
  @Published public var width: Hz = 0

  public enum Property: String {
    case depth
    case frequency = "freq"
    case permanent
    case width
  }
  
  public enum Depth : UInt {
    case normal   = 1
    case deep     = 2
    case veryDeep = 3
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Instance methods

  /// Parse Tnf key/value pairs
  /// - Parameter properties: a KeyValuesArray
  public  func parse(_ properties: KeyValuesArray) async {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = Property(rawValue: property.key) else {
        // log it and ignore the Key
        log("Tnf \(id): unknown token \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // known keys
      switch token {
        
      case .depth:      depth = property.value.uValue
      case .frequency:  frequency = property.value.mhzToHz
      case .permanent:  permanent = property.value.bValue
      case .width:      width = property.value.mhzToHz
      }
      // is it initialized?
      if initialized == false && frequency != 0 {
        // NO, it is now
        initialized = true
        log("Tnf \(id): initialized frequency = \(frequency)", .debug, #function, #file, #line)
      }
    }
  }


  
  
  
  
  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         a Tnf Id
  ///   - property:   a Tnf Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, _ id: TnfId, property: Property, value: Any) {
    switch property {
    case .depth:       sendCommand( radio, id, .depth, value)
    case .frequency:   sendCommand( radio, id, .frequency, (value as! Hz).hzToMhz)
    case .permanent:   sendCommand( radio, id, .permanent, (value as! Bool).as1or0)
    case .width:       sendCommand( radio, id, .width, (value as! Hz).hzToMhz)
    }
  }

  /// Send a command to Set a Tnf property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Tnf
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: TnfId, _ token: Property, _ value: Any) {
    radio.send("tnf set " + "\(id) " + token.rawValue + "=\(value)")
  }
}
