//
//  Gps.swift
//  Components6000/Radio/Objects
//
//  Created by Douglas Adams on 8/15/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation

import Shared
// import LogProxy

/// Gps Class implementation
///
///      creates a Gps instance to be used by a Client to support the
///      processing of the internal Gps (if installed). Gps structs are added,
///      removed and updated by the incoming TCP messages.
///
public struct Gps {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public internal(set) var altitude = ""
  public internal(set) var frequencyError: Double = 0
  public internal(set) var grid = ""
  public internal(set) var latitude = ""
  public internal(set) var longitude = ""
  public internal(set) var speed = ""
  public internal(set) var status = false
  public internal(set) var time = ""
  public internal(set) var track: Double = 0
  public internal(set) var tracked = false
  public internal(set) var visible = false
  
  public  enum GpsToken: String {
    case altitude
    case frequencyError = "freq_error"
    case grid
    case latitude = "lat"
    case longitude = "lon"
    case speed
    case status
    case time
    case track
    case tracked
    case visible
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public static methods

  /// Parse a Gps status message
  /// - Parameter properties:       a KeyValuesArray
  public mutating func parseProperties(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // Check for Unknown Keys
      guard let token = GpsToken(rawValue: property.key)  else {
        // log it and ignore the Key
        log("Gps, unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // Known tokens, in alphabetical order
      switch token {
      case .altitude:       altitude = property.value
      case .frequencyError: frequencyError = property.value.dValue
      case .grid:           grid = property.value
      case .latitude:       latitude = property.value
      case .longitude:      longitude = property.value
      case .speed:          speed = property.value
      case .status:         status = property.value == "present" ? true : false
      case .time:           time = property.value
      case .track:          track = property.value.dValue
      case .tracked:        tracked = property.value.bValue
      case .visible:        visible = property.value.bValue
      }
    }
  }
  
  ///   Gps Install
  ///   - Parameters:
  ///     - callback:           ReplyHandler (optional)
  public static func gpsInstall(radio: Radio, callback: ReplyHandler? = nil) {
   radio.send("radio gps install", replyTo: callback)
  }
  
  /// Gps Un-Install
  /// - Parameters:
  ///   - callback:           ReplyHandler (optional)
  public static func gpsUnInstall(radio: Radio, callback: ReplyHandler? = nil) {
    radio.send("radio gps uninstall", replyTo: callback)
  }

  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - property:   a Gps Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, _ property: GpsToken, value: Any) {
    // FIXME: add commands
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods

  /// Send a command to Set a Gps property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ token: GpsToken, _ value: Any) {
    // FIXME: add commands
  }
}
