//
//  Wan.swift
//  Components6000/Radio/Objects
//
//  Created by Douglas Adams on 8/17/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation

import Shared

// Wan Class implementation
//
//      creates a Wan instance to be used by a Client to support the
//      processing of the Wan-related activities. Wan structs are added,
//      removed and updated by the incoming TCP messages.

public struct Wan {

  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public internal(set) var initialized  = false
  public internal(set) var radioAuthenticated: Bool = false
  public internal(set) var serverConnected: Bool = false
  
  public enum WanToken: String {
    case serverConnected    = "server_connected"
    case radioAuthenticated = "radio_authenticated"
  }
    
  // ------------------------------------------------------------------------------
  // MARK: - Instance methods

  /// Parse a Wan status message
  /// - Parameter properties:       a KeyValuesArray
  public static func parseProperties(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // Check for Unknown Keys
      guard let token = WanToken(rawValue: property.key)  else {
        // log it and ignore the Key
        log("Wan: unknown token, \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // Known tokens, in alphabetical order
      switch token {
        
      case .serverConnected:    Model.shared.wan.serverConnected = property.value.bValue
      case .radioAuthenticated: Model.shared.wan.radioAuthenticated = property.value.bValue
      }
    }
    // is it initialized?
    if !Model.shared.wan.initialized {
      // NO, it is now
      Model.shared.wan.initialized = true
      log("Wan: initialized ServerConnected = \(Model.shared.wan.serverConnected), RadioAuthenticated = \(Model.shared.wan.radioAuthenticated)", .debug, #function, #file, #line)
    }
  }
}
