//
//  Atu.swift
//  
//
//  Created by Douglas Adams on 6/10/22.
//

import Foundation
import IdentifiedCollections

import Shared

// Atu Actor implementation
//      creates an Atu instance to be used by a Client to support the
//      processing of the internal Gps (if installed). Atu actors are added,
//      removed and updated by the incoming TCP messages.

public actor Atu {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public var initialized = false
  public var memoriesEnabled = false
  public var status = ""       // FIXME: ?????
  public var enabled = false
  public var usingMemory = false
  
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
  // MARK: - Initialization
  
  public init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  /// Parse Tnf key/value pairs
  /// - Parameter properties: a KeyValuesArray
  public func parseProperties(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = AtuToken(rawValue: property.key) else {
        // log it and ignore the Key
        log("Atu: unknown token \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // known keys
      switch token {
        
      case .enabled:          enabled = property.value.bValue
      case .memoriesEnabled:  memoriesEnabled = property.value.bValue
      case .status:           status = property.value
      case .usingMemory:      usingMemory = property.value.bValue
      }
      // is it initialized?
      if initialized == false {
        // NO, it is now
        initialized = true
        log("Atu: initialized", .debug, #function, #file, #line)
      }
    }
    updateModel()
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  private func updateModel() {
    Task {
      await Model.shared.setAtu(self)
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - property:   an Atu Token
  ///   - value:      the new value
  public static nonisolated func setProperty(radio: Radio, _ token: AtuToken, value: Any) {
    sendCommand( radio, token, value)
  }
  public static nonisolated func clear(_ radio: Radio, callback: ReplyHandler? = nil) {
    radio.send("atu clear", replyTo: callback)
  }
  public static nonisolated func start(_ radio: Radio, callback: ReplyHandler? = nil) {
    radio.send("atu start", replyTo: callback)
  }
  public static nonisolated func bypass(_ radio: Radio, callback: ReplyHandler? = nil) {
    radio.send("atu bypass", replyTo: callback)
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Send a command to Set an Atu property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ token: AtuToken, _ value: Any) {
    
    // FIXME: condition????
    
    if true {
      radio.send("atu " + token.rawValue + "=\(value)")
    } else {
      radio.send("atu set " + token.rawValue + "=\(value)")
    }
  }
}
