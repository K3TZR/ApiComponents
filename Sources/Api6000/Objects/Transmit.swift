//
//  Transmit.swift
//  Components6000/Radio/Objects
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
//public final class Transmit: ObservableObject {
public struct Transmit {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public internal(set) var initialized = false
  
  public internal(set) var carrierLevel = 0
  public internal(set) var companderEnabled = false
  public internal(set) var companderLevel = 0
  public internal(set) var cwBreakInDelay = 0
  public internal(set) var cwBreakInEnabled = false
  public internal(set) var cwIambicEnabled = false
  public internal(set) var cwIambicMode = 0
  public internal(set) var cwlEnabled = false
  public internal(set) var cwPitch = 0
  public internal(set) var cwSidetoneEnabled = false
  public internal(set) var cwSpeed = 0
  public internal(set) var cwSwapPaddles = false
  public internal(set) var cwSyncCwxEnabled = false
  public internal(set) var daxEnabled = false
  public internal(set) var frequency: Hz = 0
  public internal(set) var hwAlcEnabled = false
  public internal(set) var inhibit = false
  public internal(set) var maxPowerLevel = 0
  public internal(set) var metInRxEnabled = false
  public internal(set) var micAccEnabled = false
  public internal(set) var micBiasEnabled = false
  public internal(set) var micBoostEnabled = false
  public internal(set) var micLevel = 0
  public internal(set) var micSelection = ""
  public internal(set) var rawIqEnabled = false
  public internal(set) var rfPower = 0
  public internal(set) var speechProcessorEnabled = false
  public internal(set) var speechProcessorLevel = 0
  public internal(set) var tune = false
  public internal(set) var tunePower = 0
  public internal(set) var txAntenna = ""
  public internal(set) var txFilterChanges = false
  public internal(set) var txFilterHigh = 0
  public internal(set) var txFilterLow = 0
  public internal(set) var txInWaterfallEnabled = false
  public internal(set) var txMonitorAvailable = false
  public internal(set) var txMonitorEnabled = false
  public internal(set) var txMonitorGainCw = 0
  public internal(set) var txMonitorGainSb = 0
  public internal(set) var txMonitorPanCw = 0
  public internal(set) var txMonitorPanSb = 0
  public internal(set) var txRfPowerChanges = false
  public internal(set) var txSliceMode = ""
  public internal(set) var voxEnabled = false
  public internal(set) var voxDelay = 0
  public internal(set) var voxLevel = 0
  
  public enum TransmitToken: String {
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
  // MARK: - Private methods
  
  //    private func txFilterHighLimits(_ low: Int, _ high: Int) -> Int {
  //        let newValue = ( high < low + 50 ? low + 50 : high )
  //        return newValue > 10_000 ? 10_000 : newValue
  //    }
  //
  //    private func txFilterLowLimits(_ low: Int, _ high: Int) -> Int {
  //        let newValue = ( low > high - 50 ? high - 50 : low )
  //        return newValue < 0 ? 0 : newValue
  //    }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Parse a Transmit status message
  /// - Parameter properties:       a KeyValuesArray
  public static func parseProperties(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // Check for Unknown Keys
      guard let token = TransmitToken(rawValue: property.key)  else {
        // log it and ignore the Key
        log("Transmit, unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // Known tokens, in alphabetical order
      switch token {
        
      case .amCarrierLevel:         Model.shared.transmit.carrierLevel = property.value.iValue
      case .companderEnabled:       Model.shared.transmit.companderEnabled = property.value.bValue
      case .companderLevel:         Model.shared.transmit.companderLevel = property.value.iValue
      case .cwBreakInEnabled:       Model.shared.transmit.cwBreakInEnabled = property.value.bValue
      case .cwBreakInDelay:         Model.shared.transmit.cwBreakInDelay = property.value.iValue
      case .cwIambicEnabled:        Model.shared.transmit.cwIambicEnabled = property.value.bValue
      case .cwIambicMode:           Model.shared.transmit.cwIambicMode = property.value.iValue
      case .cwlEnabled:             Model.shared.transmit.cwlEnabled = property.value.bValue
      case .cwPitch:                Model.shared.transmit.cwPitch = property.value.iValue
      case .cwSidetoneEnabled:      Model.shared.transmit.cwSidetoneEnabled = property.value.bValue
      case .cwSpeed:                Model.shared.transmit.cwSpeed = property.value.iValue
      case .cwSwapPaddles:          Model.shared.transmit.cwSwapPaddles = property.value.bValue
      case .cwSyncCwxEnabled:       Model.shared.transmit.cwSyncCwxEnabled = property.value.bValue
      case .daxEnabled:             Model.shared.transmit.daxEnabled = property.value.bValue
      case .frequency:              Model.shared.transmit.frequency = property.value.mhzToHz
      case .hwAlcEnabled:           Model.shared.transmit.hwAlcEnabled = property.value.bValue
      case .inhibit:                Model.shared.transmit.inhibit = property.value.bValue
      case .maxPowerLevel:          Model.shared.transmit.maxPowerLevel = property.value.iValue
      case .metInRxEnabled:         Model.shared.transmit.metInRxEnabled = property.value.bValue
      case .micAccEnabled:          Model.shared.transmit.micAccEnabled = property.value.bValue
      case .micBoostEnabled:        Model.shared.transmit.micBoostEnabled = property.value.bValue
      case .micBiasEnabled:         Model.shared.transmit.micBiasEnabled = property.value.bValue
      case .micLevel:               Model.shared.transmit.micLevel = property.value.iValue
      case .micSelection:           Model.shared.transmit.micSelection = property.value
      case .rawIqEnabled:           Model.shared.transmit.rawIqEnabled = property.value.bValue
      case .rfPower:                Model.shared.transmit.rfPower = property.value.iValue
      case .speechProcessorEnabled: Model.shared.transmit.speechProcessorEnabled = property.value.bValue
      case .speechProcessorLevel:   Model.shared.transmit.speechProcessorLevel = property.value.iValue
      case .txAntenna:              Model.shared.transmit.txAntenna = property.value
      case .txFilterChanges:        Model.shared.transmit.txFilterChanges = property.value.bValue
      case .txFilterHigh:           Model.shared.transmit.txFilterHigh = property.value.iValue
      case .txFilterLow:            Model.shared.transmit.txFilterLow = property.value.iValue
      case .txInWaterfallEnabled:   Model.shared.transmit.txInWaterfallEnabled = property.value.bValue
      case .txMonitorAvailable:     Model.shared.transmit.txMonitorAvailable = property.value.bValue
      case .txMonitorEnabled:       Model.shared.transmit.txMonitorEnabled = property.value.bValue
      case .txMonitorGainCw:        Model.shared.transmit.txMonitorGainCw = property.value.iValue
      case .txMonitorGainSb:        Model.shared.transmit.txMonitorGainSb = property.value.iValue
      case .txMonitorPanCw:         Model.shared.transmit.txMonitorPanCw = property.value.iValue
      case .txMonitorPanSb:         Model.shared.transmit.txMonitorPanSb = property.value.iValue
      case .txRfPowerChanges:       Model.shared.transmit.txRfPowerChanges = property.value.bValue
      case .txSliceMode:            Model.shared.transmit.txSliceMode = property.value
      case .tune:                   Model.shared.transmit.tune = property.value.bValue
      case .tunePower:              Model.shared.transmit.tunePower = property.value.iValue
      case .voxEnabled:             Model.shared.transmit.voxEnabled = property.value.bValue
      case .voxDelay:               Model.shared.transmit.voxDelay = property.value.iValue
      case .voxLevel:               Model.shared.transmit.voxLevel = property.value.iValue
      }
    }
    // is it initialized?
    if Model.shared.transmit.initialized == false {
      // NO, it is now
      Model.shared.transmit.initialized = true
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
  public static func setProperty(radio: Radio, _ property: TransmitToken, value: Any) {
    // FIXME: add commands
  }
  
  
  /// Send a command to Set a Transmit property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ token: TransmitToken, _ value: Any) {
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
