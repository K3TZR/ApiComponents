//
//  Transmit.swift
//  Api6000Components/Api6000/Objects
//
//  Created by Douglas Adams on 8/16/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation

import Shared

/// Transmit Class implementation
///
///      creates a Transmit instance to be used by a Client to support the
///      processing of the Transmit-related activities. Transmit structs are added,
///      removed and updated by the incoming TCP messages.
///
@MainActor
public final class Transmit: ObservableObject {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public var initialized = false
  
  @Published public var carrierLevel = 0
  @Published public var companderEnabled = false
  @Published public var companderLevel = 0
  @Published public var cwBreakInDelay = 0
  @Published public var cwBreakInEnabled = false
  @Published public var cwIambicEnabled = false
  @Published public var cwIambicMode = 0
  @Published public var cwlEnabled = false
  @Published public var cwPitch = 0
  @Published public var cwSidetoneEnabled = false
  @Published public var cwSpeed = 0
  @Published public var cwSwapPaddles = false
  @Published public var cwSyncCwxEnabled = false
  @Published public var daxEnabled = false
  @Published public var frequency: Hz = 0
  @Published public var hwAlcEnabled = false
  @Published public var inhibit = false
  @Published public var maxPowerLevel = 0
  @Published public var metInRxEnabled = false
  @Published public var micAccEnabled = false
  @Published public var micBiasEnabled = false
  @Published public var micBoostEnabled = false
  @Published public var micLevel = 0
  @Published public var micSelection = ""
  @Published public var rawIqEnabled = false
  @Published public var rfPower = 0
  @Published public var speechProcessorEnabled = false
  @Published public var speechProcessorLevel = 0
  @Published public var tune = false
  @Published public var tunePower = 0
  @Published public var txAntenna = ""
  @Published public var txFilterChanges = false
  @Published public var txFilterHigh = 0
  @Published public var txFilterLow = 0
  @Published public var txInWaterfallEnabled = false
  @Published public var txMonitorAvailable = false
  @Published public var txMonitorEnabled = false
  @Published public var txMonitorGainCw = 0
  @Published public var txMonitorGainSb = 0
  @Published public var txMonitorPanCw = 0
  @Published public var txMonitorPanSb = 0
  @Published public var txRfPowerChanges = false
  @Published public var txSliceMode = ""
  @Published public var voxEnabled = false
  @Published public var voxDelay = 0
  @Published public var voxLevel = 0
  
  public enum Property: String {
    case amCarrierLevel           = "am_carrier_level"              // "am_carrier"
    case companderEnabled         = "compander"
    case companderLevel           = "compander_level"
    case cwBreakInDelay           = "break_in_delay"
    case cwBreakInEnabled         = "break_in"
    case cwIambicEnabled          = "iambic"
    case cwIambicMode             = "iambic_mode"                   // "mode"
    case cwlEnabled               = "cwl_enabled"
    case cwPitch                  = "pitch"
    case cwSidetoneEnabled        = "sidetone"
    case cwSpeed                  = "speed"                         // "wpm"
    case cwSwapPaddles            = "swap_paddles"                  // "swap"
    case cwSyncCwxEnabled         = "synccwx"
    case daxEnabled               = "dax"
    case frequency                = "freq"
    case hwAlcEnabled             = "hwalc_enabled"
    case inhibit
    case maxPowerLevel            = "max_power_level"
    case metInRxEnabled           = "met_in_rx"
    case micAccEnabled            = "mic_acc"                       // "acc"
    case micBoostEnabled          = "mic_boost"                     // "boost"
    case micBiasEnabled           = "mic_bias"                      // "bias"
    case micLevel                 = "mic_level"                     // "miclevel"
    case micSelection             = "mic_selection"                 // "input"
    case rawIqEnabled             = "raw_iq_enable"
    case rfPower                  = "rfpower"
    case speechProcessorEnabled   = "speech_processor_enable"
    case speechProcessorLevel     = "speech_processor_level"
    case tune
    case tunePower                = "tunepower"
    case txAntenna                = "tx_antenna"
    case txFilterChanges          = "tx_filter_changes_allowed"
    case txFilterHigh             = "hi"                            // "filter_high"
    case txFilterLow              = "lo"                            // "filter_low"
    case txInWaterfallEnabled     = "show_tx_in_waterfall"
    case txMonitorAvailable       = "mon_available"
    case txMonitorEnabled         = "sb_monitor"                    // "mon"
    case txMonitorGainCw          = "mon_gain_cw"
    case txMonitorGainSb          = "mon_gain_sb"
    case txMonitorPanCw           = "mon_pan_cw"
    case txMonitorPanSb           = "mon_pan_sb"
    case txRfPowerChanges         = "tx_rf_power_changes_allowed"
    case txSliceMode              = "tx_slice_mode"
    case voxEnabled               = "vox_enable"
    case voxDelay                 = "vox_delay"
    case voxLevel                 = "vox_level"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Instance methods
  
  /// Parse a Transmit status message
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) async {
    // process each key/value pair, <key=value>
    for property in properties {
      // Check for Unknown Keys
      guard let token = Property(rawValue: property.key)  else {
        // log it and ignore the Key
        log("Transmit, unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // Known tokens, in alphabetical order
      switch token {
        
      case .amCarrierLevel:         carrierLevel = property.value.iValue
      case .companderEnabled:       companderEnabled = property.value.bValue
      case .companderLevel:         companderLevel = property.value.iValue
      case .cwBreakInEnabled:       cwBreakInEnabled = property.value.bValue
      case .cwBreakInDelay:         cwBreakInDelay = property.value.iValue
      case .cwIambicEnabled:        cwIambicEnabled = property.value.bValue
      case .cwIambicMode:           cwIambicMode = property.value.iValue
      case .cwlEnabled:             cwlEnabled = property.value.bValue
      case .cwPitch:                cwPitch = property.value.iValue
      case .cwSidetoneEnabled:      cwSidetoneEnabled = property.value.bValue
      case .cwSpeed:                cwSpeed = property.value.iValue
      case .cwSwapPaddles:          cwSwapPaddles = property.value.bValue
      case .cwSyncCwxEnabled:       cwSyncCwxEnabled = property.value.bValue
      case .daxEnabled:             daxEnabled = property.value.bValue
      case .frequency:              frequency = property.value.mhzToHz
      case .hwAlcEnabled:           hwAlcEnabled = property.value.bValue
      case .inhibit:                inhibit = property.value.bValue
      case .maxPowerLevel:          maxPowerLevel = property.value.iValue
      case .metInRxEnabled:         metInRxEnabled = property.value.bValue
      case .micAccEnabled:          micAccEnabled = property.value.bValue
      case .micBoostEnabled:        micBoostEnabled = property.value.bValue
      case .micBiasEnabled:         micBiasEnabled = property.value.bValue
      case .micLevel:               micLevel = property.value.iValue
      case .micSelection:           micSelection = property.value
      case .rawIqEnabled:           rawIqEnabled = property.value.bValue
      case .rfPower:                rfPower = property.value.iValue
      case .speechProcessorEnabled: speechProcessorEnabled = property.value.bValue
      case .speechProcessorLevel:   speechProcessorLevel = property.value.iValue
      case .txAntenna:              txAntenna = property.value
      case .txFilterChanges:        txFilterChanges = property.value.bValue
      case .txFilterHigh:           txFilterHigh = property.value.iValue
      case .txFilterLow:            txFilterLow = property.value.iValue
      case .txInWaterfallEnabled:   txInWaterfallEnabled = property.value.bValue
      case .txMonitorAvailable:     txMonitorAvailable = property.value.bValue
      case .txMonitorEnabled:       txMonitorEnabled = property.value.bValue
      case .txMonitorGainCw:        txMonitorGainCw = property.value.iValue
      case .txMonitorGainSb:        txMonitorGainSb = property.value.iValue
      case .txMonitorPanCw:         txMonitorPanCw = property.value.iValue
      case .txMonitorPanSb:         txMonitorPanSb = property.value.iValue
      case .txRfPowerChanges:       txRfPowerChanges = property.value.bValue
      case .txSliceMode:            txSliceMode = property.value
      case .tune:                   tune = property.value.bValue
      case .tunePower:              tunePower = property.value.iValue
      case .voxEnabled:             voxEnabled = property.value.bValue
      case .voxDelay:               voxDelay = property.value.iValue
      case .voxLevel:               voxLevel = property.value.iValue
      }
    }
    // is it initialized?
    if initialized == false {
      // NO, it is now
      initialized = true
      log("Transmit: initialized", .debug, #function, #file, #line)
    }
  }

  
  
  
  
  
  
  
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - property:   a Transmit Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, _ property: Property, value: Any) {
    // FIXME: add commands
  }
  
  
  /// Send a command to Set a Transmit property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ token: Property, _ value: Any) {
    // FIXME: add commands
  }
  
  //    private func cwCmd(_ token: TransmitTokens, _ value: Any) {
  //        Api.sharedInstance.send("cw " + token.rawValue + " \(value)")
  //    }
  //    private func micCmd(_ token: TransmitTokens, _ value: Any) {
  //        Api.sharedInstance.send("mic " + token.rawValue + " \(value)")
  //    }
  //    private func transmitCmd(_ token: TransmitTokens, _ value: Any) {
  //        Api.sharedInstance.send("transmit set " + token.rawValue + "=\(value)")
  //    }
  //    private func tuneCmd(_ token: TransmitTokens, _ value: Any) {
  //        Api.sharedInstance.send("transmit " + token.rawValue + " \(value)")
  //    }
  //
  //    // alternate forms for commands that do not use the Token raw value in outgoing messages
  //
  //    private func cwCmd(_ tokenString: String, _ value: Any) {
  //        Api.sharedInstance.send("cw " + tokenString + " \(value)")
  //    }
  //    private func micCmd(_ tokenString: String, _ value: Any) {
  //        Api.sharedInstance.send("mic " + tokenString + " \(value)")
  //    }
  //    private func transmitCmd(_ tokenString: String, _ value: Any) {
  //        Api.sharedInstance.send("transmit set " + tokenString + "=\(value)")
  //    }
}
