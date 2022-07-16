//
//  Waveform.swift
//  Api6000Components/Api6000/Objects
//
//  Created by Douglas Adams on 8/17/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation

import Shared

// Waveform
//
//      creates a Waveform instance to be used by a Client to support the
//      processing of installed Waveform functions. The Waveform list is
//      updated by the incoming TCP messages.
@MainActor
public class Waveform: ObservableObject {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  @Published public var waveformList = ""
  
  public enum Property: String {
    case waveformList = "installed_list"
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Instance methods
  
  /// Parse a Waveform status message
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) async {
    // process each key/value pair, <key=value>
    for property in properties {
      // Check for Unknown Keys
      guard let token = Property(rawValue: property.key)  else {
        // log it and ignore the Key
        log("Waveform, unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // Known tokens, in alphabetical order
      switch token {
        
      case .waveformList:   waveformList = property.value
      }
    }
  }
}
