//
//  Wan.swift
//  
//
//  Created by Douglas Adams on 6/11/22.
//

import Foundation

import Shared

// Wan Actor implementation
//
//      creates a Wan instance to be used by a Client to support the
//      processing of the Wan-related activities. Wan actors are added,
//      removed and updated by the incoming TCP messages.

public actor Wan {
  
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
  // MARK: - Public methods
  
  /// Parse a Wan status message
  /// - Parameter properties:       a KeyValuesArray
  public func parseProperties(_ properties: KeyValuesArray) {
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
        
      case .serverConnected:    serverConnected = property.value.bValue
      case .radioAuthenticated: radioAuthenticated = property.value.bValue
      }
    }
    // is it initialized?
    if !initialized {
      // NO, it is now
      initialized = true
      log("Wan: initialized ServerConnected = \(serverConnected), RadioAuthenticated = \(radioAuthenticated)", .debug, #function, #file, #line)
    }
    updateModel()
  }
  
  private func updateModel() {
    Task {
      await Model.shared.setWan(self)
    }
  }
}
