//
//  Amplifier.swift
//  Components6000/Radio/Objects
//
//  Created by Douglas Adams on 8/7/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation

import Shared

// Amplifier Struct
//       creates an Amplifier instance to be used by a Client to support the
//       control of an external Amplifier. Amplifier structs are added, removed and
//       updated by the incoming TCP messages. They are collected in the
//       Model.amplifiers collection.

public struct Amplifier: Identifiable, Equatable {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public internal(set) var id: AmplifierId
  public internal(set) var initialized = false

  public internal(set) var ant: String = ""
  public internal(set) var antennaDict = [String:String]()
  public internal(set) var handle: Handle = 0
  public internal(set) var ip: String = ""
  public internal(set) var model: String = ""
  public internal(set) var port: Int = 0
  public internal(set) var serialNumber: String = ""
  public internal(set) var state: String = ""
  
  public enum AmplifierToken : String {
    case ant
    case handle
    case ip
    case model
    case port
    case serialNumber         = "serial_num"
    case state
  }

  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: AmplifierId) { self.id = id }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  // Equality
  public static func == (lhs: Amplifier, rhs: Amplifier) -> Bool {
    lhs.id == rhs.id
  }

  /// Parse an Amplifier status message
  /// - Parameters:
  ///   - properties:     a KeyValuesArray of Amplifier properties
  ///   - inUse:          false = "to be deleted"
  public static func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id
    if let id = properties[0].key.handle {
      // is the object in use?
      if inUse {
        // YES, does it exist?
        if Model.shared.amplifiers[id: id] == nil {
          // NO, create a new Amplifier & add it to the Amplifiers collection
          Model.shared.amplifiers[id: id] = Amplifier(id)
          log("Amplifier \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values to the Amplifier for parsing
        Model.shared.amplifiers[id: id]?.parseProperties( Array(properties.dropFirst(1)) )
      } else {
        // NO, does it exist?
        if Model.shared.amplifiers[id: id] != nil {
          // YES, remove it
          remove(id)
        }
      }
    }
  }

  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         an Amplifier Id
  ///   - property:   an Amplifier Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, _ id: AmplifierId, property: AmplifierToken, value: Any) {
    // FIXME: add commands
  }

//  public func getProperty( _ id: AmplifierId, property: AmplifierToken) -> Any? {
//    switch property {
//
//    case .ant:          return Model.shared.amplifiers[id: id]!.ant as Any
//    case .handle:       return Model.shared.amplifiers[id: id]!.handle as Any
//    case .ip:           return Model.shared.amplifiers[id: id]!.ip as Any
//    case .model:        return Model.shared.amplifiers[id: id]!.model as Any
//    case .port:         return Model.shared.amplifiers[id: id]!.port as Any
//    case .serialNumber: return Model.shared.amplifiers[id: id]!.serialNumber as Any
//    case .state:        return Model.shared.amplifiers[id: id]!.state as Any
//    }
//  }

  /// Remove the specified Amplifier
  /// - Parameter id:     an AmplifierId
  public static func remove(_ id: AmplifierId) {
    Model.shared.amplifiers.remove(id: id)
    log("Amplifier \(id.hex): removed", .debug, #function, #file, #line)
  }
 
  /// Remove all Amplifiers
  public static func removeAll() {
    for amplifier in Model.shared.amplifiers {
      remove(amplifier.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Parse Tnf key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private mutating func parseProperties(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = AmplifierToken(rawValue: property.key) else {
        // log it and ignore the Key
        log("Amplifier \(id) unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // known keys
      switch token {
        
      case .ant:          ant = property.value ; antennaDict = parseAntennaSettings( property.value)
      case .handle:       handle = property.value.handle ?? 0
      case .ip:           ip = property.value
      case .model:        model = property.value
      case .port:         port = property.value.iValue
      case .serialNumber: serialNumber = property.value
      case .state:        state = property.value
      }
      // is it initialized?
      if initialized == false {
        // NO, it is now
        initialized = true
        log("Amplifier \(id.hex): initialized", .debug, #function, #file, #line)
      }
    }
  }
  
  /// Parse a list of antenna pairs
  /// - Parameter settings:     the list
  private func parseAntennaSettings(_ settings: String) -> [String:String] {
    var antDict = [String:String]()
    
    // pairs are comma delimited
    let pairs = settings.split(separator: ",")
    // each setting is <ant:ant>
    for setting in pairs {
      if !setting.contains(":") { continue }
      let parts = setting.split(separator: ":")
      if parts.count != 2 {continue }
      antDict[String(parts[0])] = String(parts[1])
    }
    return antDict
  }

  /// Send a command to Set an Amplifier property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Amplifier
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: AmplifierId, _ token: AmplifierToken, _ value: Any) {
    // FIXME: add commands
  }
}

