//
//  Wan.swift
//  Api6000Components/Api6000/Objects
//
//  Created by Douglas Adams on 8/17/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation

import Shared

// Wan
//      creates a Wan instance to be used by a Client to support the
//      processing of the Wan-related activities. Wan instance is
//      updated by the incoming TCP messages.
@MainActor
public class Wan: ObservableObject {

  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public internal(set) var initialized  = false
  public internal(set) var radioAuthenticated: Bool = false
  public internal(set) var serverConnected: Bool = false
  
  public enum Property: String {
    case serverConnected    = "server_connected"
    case radioAuthenticated = "radio_authenticated"
  }
    
  // ------------------------------------------------------------------------------
  // MARK: - Public Instance methods

  /// Parse status message
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) async {
    // process each key/value pair, <key=value>
    for property in properties {
      // Check for Unknown Keys
      guard let token = Property(rawValue: property.key)  else {
        // log it and ignore the Key
        log("Wan: unknown token, \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // Known tokens, in alphabetical order
      switch token {
        
      case .serverConnected:      serverConnected = property.value.bValue
      case .radioAuthenticated:   radioAuthenticated = property.value.bValue
      }
    }
    // is it initialized?
    if initialized {
      // NO, it is now
      initialized = true
      log("Wan: initialized ServerConnected = \(serverConnected), RadioAuthenticated = \(radioAuthenticated)", .debug, #function, #file, #line)
    }
  }
}
