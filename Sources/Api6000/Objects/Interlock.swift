//
//  Interlock.swift
//  Api6000Components/Api6000/Objects
//
//  Created by Douglas Adams on 8/16/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation

import Shared

// Interlock Class implementation
//      creates an Interlock instance to be used by a Client to support the
//      processing of interlocks. Interlock structs are added, removed and
//      updated by the incoming TCP messages.

public struct Interlock {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties

  public var accTxEnabled = false
  public var accTxDelay = 0
  public var accTxReqEnabled = false
  public var accTxReqPolarity = false
  public var amplifier = ""
  public var rcaTxReqEnabled = false
  public var rcaTxReqPolarity = false
  public var reason = ""
  public var source = ""
  public var state = ""
  public var timeout = 0
  public var txAllowed = false
  public var txClientHandle: Handle = 0
  public var txDelay = 0
  public var tx1Enabled = false
  public var tx1Delay = 0
  public var tx2Enabled = false
  public var tx2Delay = 0
  public var tx3Enabled = false
  public var tx3Delay = 0

  public enum InterlockToken: String {
    case accTxEnabled       = "acc_tx_enabled"
    case accTxDelay         = "acc_tx_delay"
    case accTxReqEnabled    = "acc_txreq_enable"
    case accTxReqPolarity   = "acc_txreq_polarity"
    case amplifier
    case rcaTxReqEnabled    = "rca_txreq_enable"
    case rcaTxReqPolarity   = "rca_txreq_polarity"
    case reason
    case source
    case state
    case timeout
    case txAllowed          = "tx_allowed"
    case txClientHandle     = "tx_client_handle"
    case txDelay            = "tx_delay"
    case tx1Enabled         = "tx1_enabled"
    case tx1Delay           = "tx1_delay"
    case tx2Enabled         = "tx2_enabled"
    case tx2Delay           = "tx2_delay"
    case tx3Enabled         = "tx3_enabled"
    case tx3Delay           = "tx3_delay"
  }
  public enum States: String {
    case receive            = "RECEIVE"
    case ready              = "READY"
    case notReady           = "NOT_READY"
    case pttRequested       = "PTT_REQUESTED"
    case transmitting       = "TRANSMITTING"
    case txFault            = "TX_FAULT"
    case timeout            = "TIMEOUT"
    case stuckInput         = "STUCK_INPUT"
    case unKeyRequested     = "UNKEY_REQUESTED"
  }
  public enum PttSources: String {
    case software           = "SW"
    case mic                = "MIC"
    case acc                = "ACC"
    case rca                = "RCA"
  }
  public enum Reasons: String {
    case rcaTxRequest       = "RCA_TXREQ"
    case accTxRequest       = "ACC_TXREQ"
    case badMode            = "BAD_MODE"
    case tooFar             = "TOO_FAR"
    case outOfBand          = "OUT_OF_BAND"
    case paRange            = "PA_RANGE"
    case clientTxInhibit    = "CLIENT_TX_INHIBIT"
    case xvtrRxOnly         = "XVTR_RX_OLY"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods

  /// Parse an Interlock status message
  /// - Parameter properties:       a KeyValuesArray
  public static  func parseProperties(_ properties: KeyValuesArray) {
    // NO, process each key/value pair, <key=value>
    for property in properties {
      // Check for Unknown Keys
      guard let token = InterlockToken(rawValue: property.key)  else {
        // log it and ignore the Key
        log("Interlock, unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // Known tokens, in alphabetical order
      switch token {

      case .accTxEnabled:     Model.shared.interlock.accTxEnabled = property.value.bValue
      case .accTxDelay:       Model.shared.interlock.accTxDelay = property.value.iValue
      case .accTxReqEnabled:  Model.shared.interlock.accTxReqEnabled = property.value.bValue
      case .accTxReqPolarity: Model.shared.interlock.accTxReqPolarity = property.value.bValue
      case .amplifier:        Model.shared.interlock.amplifier = property.value
      case .rcaTxReqEnabled:  Model.shared.interlock.rcaTxReqEnabled = property.value.bValue
      case .rcaTxReqPolarity: Model.shared.interlock.rcaTxReqPolarity = property.value.bValue
      case .reason:           Model.shared.interlock.reason = property.value
      case .source:           Model.shared.interlock.source = property.value
      case .state:            Model.shared.interlock.state = property.value
      case .timeout:          Model.shared.interlock.timeout = property.value.iValue
      case .txAllowed:        Model.shared.interlock.txAllowed = property.value.bValue
      case .txClientHandle:   Model.shared.interlock.txClientHandle = property.value.handle ?? 0
      case .txDelay:          Model.shared.interlock.txDelay = property.value.iValue
      case .tx1Delay:         Model.shared.interlock.tx1Delay = property.value.iValue
      case .tx1Enabled:       Model.shared.interlock.tx1Enabled = property.value.bValue
      case .tx2Delay:         Model.shared.interlock.tx2Delay = property.value.iValue
      case .tx2Enabled:       Model.shared.interlock.tx2Enabled = property.value.bValue
      case .tx3Delay:         Model.shared.interlock.tx3Delay = property.value.iValue
      case .tx3Enabled:       Model.shared.interlock.tx3Enabled = property.value.bValue
      }
    }
  }

  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - token:      an Interlock Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, _ token: InterlockToken, value: Any) {
    // FIXME: add commands
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods

  /// Send a command to Set an InterlockToken property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ token: InterlockToken, _ value: Any) {
    // FIXME: add commands
  }
}
