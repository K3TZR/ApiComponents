//
//  Waveform.swift
//  Components6000/Radio/Objects
//
//  Created by Douglas Adams on 8/17/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation

import Shared

// Waveform Class implementation
//
//      creates a Waveform instance to be used by a Client to support the
//      processing of installed Waveform functions. Waveform structs are added,
//      removed and updated by the incoming TCP messages.

public struct Waveform {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public internal(set) var waveformList = ""
  
  public enum WaveformToken: String {
    case waveformList = "installed_list"
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Parse a Waveform status message
  /// - Parameter properties:       a KeyValuesArray
  public static func parseProperties(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // Check for Unknown Keys
      guard let token = WaveformToken(rawValue: property.key)  else {
        // log it and ignore the Key
        log("Waveform, unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // Known tokens, in alphabetical order
      switch token {
        
      case .waveformList:   Model.shared.waveform.waveformList = property.value
      }
    }
  }
}
