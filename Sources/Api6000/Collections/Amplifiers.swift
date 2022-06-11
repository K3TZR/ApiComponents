//
//  Amplifiers.swift
//  
//
//  Created by Douglas Adams on 6/10/22.
//

import Foundation
import IdentifiedCollections

import Shared

public actor Amplifiers {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public enum AmplifierToken: String {
    case ant
    case handle
    case ip
    case model
    case port
    case serialNumber = "serial_num"
    case state
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _amplifiers = IdentifiedArrayOf<Amplifier>()
  
  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = Amplifiers()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func add(_ amplifier: Amplifier) {
    _amplifiers[id: amplifier.id] = amplifier
    updateModel()
  }
  
  public func exists(id: AmplifierId) -> Bool {
    _amplifiers[id: id] != nil
  }
  
  /// Parse an Amplifier status message
  /// - Parameters:
  ///   - properties:     a KeyValuesArray of Amplifier properties
  ///   - inUse:          false = "to be deleted"
  public func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) async {
    // get the Id
    if let id = properties[0].key.handle {
      // is the object in use?
      if inUse {
        // YES, does it exist?
        if !exists(id: id) {
          // NO, create a new Amplifier & add it to the Amplifiers collection
          add( Amplifier(id) )
          log("Amplifier \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values to the Amplifier for parsing
        parseProperties(id, Array(properties.dropFirst(1)) )
      } else {
        remove(id)
      }
    }
  }

  /// Remove an Amplifier
  /// - Parameter id:   a Amplifier Id
  public func remove(_ id: AmplifierId)  {
    _amplifiers.remove(id: id)
    log("Amplifier \(id.hex): removed", .debug, #function, #file, #line)

    updateModel()
  }
  
  /// Remove all Amplifiers
  public func removeAll()  {
    for amplifier in _amplifiers {
      remove(amplifier.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Parse Tnf key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private func parseProperties(_ id: AmplifierId, _ properties: KeyValuesArray) {
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
        
      case .ant:          _amplifiers[id: id]?.ant = property.value ; _amplifiers[id: id]?.antennaDict = parseAntennaSettings( property.value)
      case .handle:       _amplifiers[id: id]?.handle = property.value.handle ?? 0
      case .ip:           _amplifiers[id: id]?.ip = property.value
      case .model:        _amplifiers[id: id]?.model = property.value
      case .port:         _amplifiers[id: id]?.port = property.value.iValue
      case .serialNumber: _amplifiers[id: id]?.serialNumber = property.value
      case .state:        _amplifiers[id: id]?.state = property.value
      }
      // is it initialized?
      if _amplifiers[id: id]?.initialized == false {
        // NO, it is now
        _amplifiers[id: id]?.initialized = true
        log("Amplifier \(id.hex): initialized", .debug, #function, #file, #line)
      }
    }
    updateModel()
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

  private func updateModel() {
    Task {
      await Model.shared.setAmplifiers(_amplifiers)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         a nAmplifier Id
  ///   - property:   an Amplifier Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, id: AmplifierId, property: AmplifierToken, value: Any) {
    switch property {
    case .ant:            sendCommand( radio, id, .ant, value)
    case .handle:         sendCommand( radio, id, .handle, value)
    case .ip:             sendCommand( radio, id, .ip, value)
    case .model:          sendCommand( radio, id, .model, value)
    case .port:           sendCommand( radio, id, .port, value)
    case .serialNumber:   sendCommand( radio, id, .serialNumber, value)
    case .state:          sendCommand( radio, id, .state, value)
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Send a command to Set an Amplifier property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Amplifier
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: AmplifierId, _ token: AmplifierToken, _ value: Any) {
    // FIXME:
  }
}

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
  

  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: AmplifierId) { self.id = id }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  // Equality
  public static func == (lhs: Amplifier, rhs: Amplifier) -> Bool {
    lhs.id == rhs.id
  }
}

