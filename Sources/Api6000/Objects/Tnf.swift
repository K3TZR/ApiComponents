//
//  Tnf.swift
//  Api6000Components/Api6000/Objects
//
//  Created by Douglas Adams on 6/30/15.
//  Copyright © 2015 Douglas Adams. All rights reserved.
//

import Foundation

import Shared

// TNF Struct
//       creates a Tnf instance to be used by a Client to support the
//       rendering of a Tnf. Tnf structs are added, removed and
//       updated by the incoming TCP messages. They are collected in the
//       Model.tnfs collection.

public struct Tnf: Identifiable, Equatable {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties

  public internal(set) var id: TnfId
  public internal(set) var initialized = false

  public internal(set) var depth: UInt = 0
  public internal(set) var frequency: Hz = 0
  public internal(set) var permanent = false
  public internal(set) var width: Hz = 0

  public enum TnfToken : String {
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
  // MARK: - Initialization

  public init(_ id: TnfId) { self.id = id }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods

  // Equality
  public static func == (lhs: Tnf, rhs: Tnf) -> Bool {
    lhs.id == rhs.id
  }
  
  /// Parse a Tnf status message
  /// - Parameters:
  ///   - properties:     a KeyValuesArray of Tnf properties
  ///   - inUse:          false = "to be deleted"
  public static func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // Note: Tnf does not send status on removal
    
    // get the Id
    if let id = properties[0].key.objectId {
      // is the object in use?
      if inUse {
        // YES, does it exist?
        if Model.shared.tnfs[id: id] == nil {
          // NO, create a new Tnf & add it to the Tnfs collection
          Model.shared.tnfs[id: id] = Tnf(id)
          log("Tnf \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values to the Tnf for parsing
        Model.shared.tnfs[id: id]?.parseProperties( Array(properties.dropFirst(1)) )
      }
    }
  }

  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         a Tnf Id
  ///   - property:   a Tnf Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, _ id: TnfId, property: TnfToken, value: Any) {
    switch property {
    case .depth:       sendCommand( radio, id, .depth, value)
    case .frequency:   sendCommand( radio, id, .frequency, (value as! Hz).hzToMhz)
    case .permanent:   sendCommand( radio, id, .permanent, (value as! Bool).as1or0)
    case .width:       sendCommand( radio, id, .width, (value as! Hz).hzToMhz)
    }
  }

//  public static func getProperty( _ id: TnfId, property: TnfToken) -> Any? {
//    switch property {
//    case .depth:       return Model.shared.tnfs[id: id]?.depth as Any
//    case .frequency:   return Model.shared.tnfs[id: id]?.frequency as Any
//    case .permanent:   return Model.shared.tnfs[id: id]?.permanent as Any
//    case .width:       return Model.shared.tnfs[id: id]?.width as Any
//    }
//  }
  
  /// Remove a Tnf
  /// - Parameter id:   a Tnf Id
  public static func remove(_ id: TnfId)  {
    Model.shared.tnfs.remove(id: id)
    log("Tnf \(id.hex): removed", .debug, #function, #file, #line)
  }
  
  /// Remove all Tnfs
  public static func removeAll()  {
    for tnf in Model.shared.tnfs {
      remove(tnf.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods

  /// Parse Tnf key/value pairs
  /// - Parameter properties: a KeyValuesArray
  private mutating func parseProperties(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = TnfToken(rawValue: property.key) else {
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
        log("Tnf \(id): initialized frequency = \(Model.shared.tnfs[id: id]!.frequency)", .debug, #function, #file, #line)
      }
    }
  }

  /// Send a command to Set a Tnf property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Tnf
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: TnfId, _ token: TnfToken, _ value: Any) {
    radio.send("tnf set " + "\(id) " + token.rawValue + "=\(value)")
  }
}
