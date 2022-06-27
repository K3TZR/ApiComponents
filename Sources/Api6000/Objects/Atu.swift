//
//  Atu.swift
//  Api6000Components/Api6000/Objects
//
//  Created by Douglas Adams on 8/15/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation

import Shared

// Atu Struct
//      creates an Atu instance to be used by a Client to support the
//      processing of the Antenna Tuning Unit (if installed). Atu structs are
//      added, removed and updated by the incoming TCP messages.

public class Atu {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
    
  public var enabled: Bool = false
  public var memoriesEnabled: Bool = false
  public var status: String = ""
  public var usingMemory: Bool = false
  
//  public var enabled : Bool {
//    get { Model.q.sync { _enabled } }
//    set { if newValue != enabled { Model.q.sync(flags: .barrier) { _enabled = newValue } }}}
//  public var memoriesEnabled : Bool {
//    get { Model.q.sync { _memoriesEnabled } }
//    set { if newValue != memoriesEnabled { Model.q.sync(flags: .barrier) { _memoriesEnabled = newValue } }}}
//  public var status : String {
//    get { Model.q.sync { _status } }
//    set { if newValue != status { Model.q.sync(flags: .barrier) { _status = newValue } }}}
//  public var usingMemory: Bool {
//    get { Model.q.sync { _usingMemory } }
//    set { if newValue != usingMemory { Model.q.sync(flags: .barrier) { _usingMemory = newValue } }}}
//
//  private var _memoriesEnabled = false
//  private var _status = ""       // FIXME: ?????
//  private var _enabled = false
//  private var _usingMemory = false
    
  // ----------------------------------------------------------------------------
  // MARK: - Public types
  
  public enum Status: String {
    case none             = "NONE"
    case tuneNotStarted   = "TUNE_NOT_STARTED"
    case tuneInProgress   = "TUNE_IN_PROGRESS"
    case tuneBypass       = "TUNE_BYPASS"           // Success Byp
    case tuneSuccessful   = "TUNE_SUCCESSFUL"       // Success
    case tuneOK           = "TUNE_OK"
    case tuneFailBypass   = "TUNE_FAIL_BYPASS"      // Byp
    case tuneFail         = "TUNE_FAIL"
    case tuneAborted      = "TUNE_ABORTED"
    case tuneManualBypass = "TUNE_MANUAL_BYPASS"    // Byp
  }
  
  public enum AtuToken: String {
    case status
    case enabled            = "atu_enabled"
    case memoriesEnabled    = "memories_enabled"
    case usingMemory        = "using_mem"
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Parse an Atu status message
  /// - Parameter properties:       a KeyValuesArray
  public static func parseProperties(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // Check for Unknown Keys
      guard let token = AtuToken(rawValue: property.key)  else {
        // log it and ignore the Key
        log("Atu, unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // Known tokens, in alphabetical order
      switch token {
        
      case .enabled:          Model.shared.atu.enabled = property.value.bValue
      case .memoriesEnabled:  Model.shared.atu.memoriesEnabled = property.value.bValue
      case .status:           Model.shared.atu.status = property.value
      case .usingMemory:      Model.shared.atu.usingMemory = property.value.bValue
      }
    }
  }
  
  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - property:   an Atu Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, _ property: AtuToken, value: Any) {
    // FIXME: add commands

//    private func atuCmd(_ radio: Radio, _ token: AtuToken, _ value: Any) {
//      radio.send("atu " + token.rawValue + "=\(value)")
//    }
//    private func atuSetCmd(_ radio: Radio, _ token: AtuToken, _ value: Any) {
//      radio.send("atu set " + token.rawValue + "=\(value)")
//    }
  }

  public static func clear(_ radio: Radio, callback: ReplyHandler? = nil) {
    radio.send("atu clear", replyTo: callback)
  }
  public static func start(_ radio: Radio, callback: ReplyHandler? = nil) {
    radio.send("atu start", replyTo: callback)
  }
  public static func bypass(_ radio: Radio, callback: ReplyHandler? = nil) {
    radio.send("atu bypass", replyTo: callback)
  }

}
