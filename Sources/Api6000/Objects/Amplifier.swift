//
//  Amplifier.swift
//  Api6000Components/Api6000/Objects
//
//  Created by Douglas Adams on 8/7/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation

import Shared
import SwiftUI

// Amplifier
//       creates an Amplifier instance to be used by a Client to support the
//       control of an external Amplifier. Amplifier instances are added, removed and
//       updated by the incoming TCP messages. They are collected in the
//       Model.amplifiers collection.
@MainActor
public class Amplifier: Identifiable, Equatable, ObservableObject {
  // Equality
  public nonisolated static func == (lhs: Amplifier, rhs: Amplifier) -> Bool {
    lhs.id == rhs.id
  }

  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: AmplifierId) { self.id = id }

  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: AmplifierId
  public var initialized = false

  @Published public var ant: String = ""
  @Published public var antennaDict = [String:String]()
  @Published public var handle: Handle = 0
  @Published public var ip: String = ""
  @Published public var model: String = ""
  @Published public var port: Int = 0
  @Published public var serialNumber: String = ""
  @Published public var state: String = ""
  
  public enum Property: String {
    case ant
    case handle
    case ip
    case model
    case port
    case serialNumber  = "serial_num"
    case state
  }
  // ----------------------------------------------------------------------------
  // MARK: - Public Instance methods
  
  /// Parse Tnf key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) async {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = Property(rawValue: property.key) else {
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
  
  public func update(_ values: [(Property, String)]) async {
    for value in values {
      await parse([(key: value.0.rawValue, value: value.1)])
    }
  }
  
  public func get(_ properties: [Property]) async -> [Any] {
    var values = [Any]()
    
    for property in properties {
      switch property {
      case .ant:          values.append(ant)
      case .handle:       values.append(handle)
      case .ip:           values.append(ip)
      case .model:        values.append(model)
      case .port:         values.append(port)
      case .serialNumber: values.append(serialNumber)
      case .state:        values.append(state)
      }
    }
    return values
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
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
  private static func sendCommand(_ radio: Radio, _ id: AmplifierId, _ token: Property, _ value: Any) {
    // FIXME: add commands
  }
}

