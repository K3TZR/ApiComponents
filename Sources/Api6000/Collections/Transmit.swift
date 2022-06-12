//
//  Transmit.swift
//  
//
//  Created by Douglas Adams on 6/11/22.
//

import Foundation

import Shared

// Transmit Actor implementation
//      creates a Transmit instance to be used by a Client to support the
//      processing of the Transmit-related activities. Transmit actors are added,
//      removed and updated by the incoming TCP messages.

public actor Transmit {
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
  // MARK: - Initialization
  
  public init() {}
  
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
  // MARK: - Public methods
  
  /// Parse a Transmit status message
  /// - Parameter properties:       a KeyValuesArray
  public  func parseProperties(_ properties: KeyValuesArray) {
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
    updateModel()
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  private func updateModel() {
    Task {
      await Model.shared.setTransmit(self)
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - property:   a Transmit Token
  ///   - value:      the new value
  public static nonisolated func setProperty(radio: Radio, _ property: TransmitToken, value: Any) {
    // FIXME: add commands
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
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
