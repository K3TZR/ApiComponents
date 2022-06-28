//
//  xLib6001.Slice.swift
//  Api6000Components/Api6000/Objects
//
//  Created by Douglas Adams on 6/2/15.
//  Copyright (c) 2015 Douglas Adams, K3TZR
//

import Foundation

import Shared

// Slice Class implementation
//
//      creates a Slice instance to be used by a Client to support the
//      rendering of a Slice. Slice classes are added, removed and
//      updated by the incoming TCP messages. They are collected in the
//      slices collection on the shared Model.

public class Slice: Equatable, Identifiable, ObservableObject {
  // Equality
  public static func == (lhs: Slice, rhs: Slice) -> Bool {
    lhs.id == rhs.id
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Static properties
  
  static let kMinOffset = -99_999 // frequency offset range
  static let kMaxOffset = 99_999
  static let filterDefaults =     // Values of filters (by mode)
  [
    "AM": [3_000, 4_000, 5_600, 6_000, 8_000, 10_000, 12_000, 14_000, 16_000, 20_000],
    "SAM": [3_000, 4_000, 5_600, 6_000, 8_000, 10_000, 12_000, 14_000, 16_000, 20_000],
    "CW": [50, 75, 100, 150, 250, 400, 800, 1_000, 1_500, 3_000],
    "USB": [1_200, 1_400, 1_600, 1_800, 2_100, 2_400, 2_700, 2_900, 3_300, 4_000],
    "LSB": [1_200, 1_400, 1_600, 1_800, 2_100, 2_400, 2_700, 2_900, 3_300, 4_000],
    "FM": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    "NFM": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    "DFM": [3_000, 4_000, 6_000, 8_000, 10_000, 12_000, 14_000, 16_000, 18_000, 20_000],
    "DIGU": [100, 200, 300, 400, 600, 1_000, 1_500, 2_000, 3_000, 5_000],
    "DIGL": [100, 200, 300, 400, 600, 1_000, 1_500, 2_000, 3_000, 5_000],
    "RTTY": [250, 300, 350, 400, 450, 500, 750, 1_000, 1_500, 3_000]
  ]

  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: SliceId
  public internal(set) var initialized: Bool = false

  public internal(set) var autoPan: Bool = false
  public internal(set) var clientHandle: Handle = 0
  public internal(set) var daxClients: Int = 0
  public internal(set) var daxTxEnabled: Bool = false
  public internal(set) var detached: Bool = false
  public internal(set) var diversityChild: Bool = false
  public internal(set) var diversityIndex: Int = 0
  public internal(set) var diversityParent: Bool = false
  public internal(set) var inUse: Bool = false
  public internal(set) var modeList = ""
  public internal(set) var nr2: Int = 0
  public internal(set) var owner: Int = 0
  public internal(set) var panadapterId: PanadapterId = 0
  public internal(set) var postDemodBypassEnabled: Bool = false
  public internal(set) var postDemodHigh: Int = 0
  public internal(set) var postDemodLow: Int = 0
  @Published public internal(set) var qskEnabled: Bool = false
  public internal(set) var recordLength: Float = 0
  public internal(set) var rxAntList = [AntennaPort]()
  public internal(set) var sliceLetter: String?
  public internal(set) var txAntList = [AntennaPort]()
  public internal(set) var wide: Bool = false
  
  public internal(set) var active: Bool = false
  @Published public internal(set) var agcMode: String = AgcMode.off.rawValue
  public internal(set) var agcOffLevel: Int = 0
  @Published public internal(set) var agcThreshold: Double = 0
  @Published public internal(set) var anfEnabled: Bool = false
  @Published public internal(set) var anfLevel: Double = 0
  public internal(set) var apfEnabled: Bool = false
  public internal(set) var apfLevel: Int = 0
  @Published public internal(set) var audioGain: Double = 0
  @Published public internal(set) var audioMute: Bool = false
  @Published public internal(set) var audioPan: Double = 0
  @Published public internal(set) var daxChannel: Int = 0
  public internal(set) var dfmPreDeEmphasisEnabled: Bool = false
  public internal(set) var digitalLowerOffset: Int = 0
  public internal(set) var digitalUpperOffset: Int = 0
  public internal(set) var diversityEnabled: Bool = false
  public internal(set) var filterHigh: Int = 0
  public internal(set) var filterLow: Int = 0
  public internal(set) var fmDeviation: Int = 0
  public internal(set) var fmRepeaterOffset: Float = 0
  public internal(set) var fmToneBurstEnabled: Bool = false
  public internal(set) var fmToneFreq: Float = 0
  public internal(set) var fmToneMode: String = ""
  @Published public internal(set) var frequency: Hz = 0
  @Published public internal(set) var locked: Bool = false
  public internal(set) var loopAEnabled: Bool = false
  public internal(set) var loopBEnabled: Bool = false
  @Published public internal(set) var mode: String = ""
  @Published public internal(set) var nbEnabled: Bool = false
  @Published public internal(set) var nbLevel: Double = 0
  @Published public internal(set) var nrEnabled: Bool = false
  @Published public internal(set) var nrLevel: Double = 0
  public internal(set) var playbackEnabled: Bool = false
  public internal(set) var recordEnabled: Bool = false
  public internal(set) var repeaterOffsetDirection: String = ""
  @Published public internal(set) var rfGain: Int = 0
  @Published public internal(set) var ritEnabled: Bool = false
  @Published public internal(set) var ritOffset: Int = 0
  public internal(set) var rttyMark: Int = 0
  public internal(set) var rttyShift: Int = 0
  @Published public internal(set) var rxAnt: String = ""
  public internal(set) var sampleRate: Int = 0
  public internal(set) var splitId: SliceId?
  public internal(set) var step: Int = 0
  public internal(set) var stepList: String = "1, 10, 50, 100, 500, 1000, 2000, 3000"
  public internal(set) var squelchEnabled: Bool = false
  public internal(set) var squelchLevel: Int = 0
  @Published public internal(set) var txAnt: String = ""
  public internal(set) var txEnabled: Bool = false
  public internal(set) var txOffsetFreq: Float = 0
  @Published public internal(set) var wnbEnabled: Bool = false
  @Published public internal(set) var wnbLevel: Double = 0
  @Published public internal(set) var xitEnabled: Bool = false
  @Published public internal(set) var xitOffset: Int = 0
  
  public var agcNames = AgcMode.names()
  public let daxChoices = Radio.kDaxChannels
  public var filters = [(value: Int, label: String)]()
  
  public enum Offset: String {
    case up
    case down
    case simplex
  }
  public enum AgcMode: String, CaseIterable {
    case off
    case slow
    case med
    case fast
    
    static func names() -> [String] {
      return [AgcMode.off.rawValue, AgcMode.slow.rawValue, AgcMode.med.rawValue, AgcMode.fast.rawValue]
    }
  }
  public enum Mode: String, CaseIterable {
    case AM
    case SAM
    case CW
    case USB
    case LSB
    case FM
    case NFM
    case DFM
    case DIGU
    case DIGL
    case RTTY
    //    case dsb
    //    case dstr
    //    case fdv
  }
  
  public enum SliceProperty: String, Equatable {
    case active
    case agcMode                    = "agc_mode"
    case agcOffLevel                = "agc_off_level"
    case agcThreshold               = "agc_threshold"
    case anfEnabled                 = "anf"
    case anfLevel                   = "anf_level"
    case apfEnabled                 = "apf"
    case apfLevel                   = "apf_level"
    case audioGain                  = "audio_gain"
    case audioLevel                 = "audio_level"
    case audioMute                  = "audio_mute"
    case audioPan                   = "audio_pan"
    case clientHandle               = "client_handle"
    case daxChannel                 = "dax"
    case daxClients                 = "dax_clients"
    case daxTxEnabled               = "dax_tx"
    case detached
    case dfmPreDeEmphasisEnabled    = "dfm_pre_de_emphasis"
    case digitalLowerOffset         = "digl_offset"
    case digitalUpperOffset         = "digu_offset"
    case diversityEnabled           = "diversity"
    case diversityChild             = "diversity_child"
    case diversityIndex             = "diversity_index"
    case diversityParent            = "diversity_parent"
    case filterHigh                 = "filter_hi"
    case filterLow                  = "filter_lo"
    case fmDeviation                = "fm_deviation"
    case fmRepeaterOffset           = "fm_repeater_offset_freq"
    case fmToneBurstEnabled         = "fm_tone_burst"
    case fmToneMode                 = "fm_tone_mode"
    case fmToneFreq                 = "fm_tone_value"
    case frequency                  = "rf_frequency"
    case ghost
    case inUse                      = "in_use"
    case locked                     = "lock"
    case loopAEnabled               = "loopa"
    case loopBEnabled               = "loopb"
    case mode
    case modeList                   = "mode_list"
    case nbEnabled                  = "nb"
    case nbLevel                    = "nb_level"
    case nrEnabled                  = "nr"
    case nrLevel                    = "nr_level"
    case nr2
    case owner
    case panadapterId               = "pan"
    case playbackEnabled            = "play"
    case postDemodBypassEnabled     = "post_demod_bypass"
    case postDemodHigh              = "post_demod_high"
    case postDemodLow               = "post_demod_low"
    case qskEnabled                 = "qsk"
    case recordEnabled              = "record"
    case recordTime                 = "record_time"
    case repeaterOffsetDirection    = "repeater_offset_dir"
    case rfGain                     = "rfgain"
    case ritEnabled                 = "rit_on"
    case ritOffset                  = "rit_freq"
    case rttyMark                   = "rtty_mark"
    case rttyShift                  = "rtty_shift"
    case rxAnt                      = "rxant"
    case rxAntList                  = "ant_list"
    case sampleRate                 = "sample_rate"
    case sliceLetter                = "index_letter"
    case squelchEnabled             = "squelch"
    case squelchLevel               = "squelch_level"
    case step
    case stepList                   = "step_list"
    case txEnabled                  = "tx"
    case txAnt                      = "txant"
    case txAntList                  = "tx_ant_list"
    case txOffsetFreq               = "tx_offset_freq"
    case wide
    case wnbEnabled                 = "wnb"
    case wnbLevel                   = "wnb_level"
    case xitEnabled                 = "xit_on"
    case xitOffset                  = "xit_freq"
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: SliceId) {
    self.id = id
    // set filterLow & filterHigh to default values
    setupDefaultFilters(mode)
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Parse a Slice status message
  /// - Parameters:
  ///   - keyValues:      a KeyValuesArray
  ///   - inUse:          false = "to be deleted"
  public static func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id
    if let id = properties[0].key.objectId {
      // is the object in use?
      if inUse {
        // YES, does it exist?
        if Model.shared.slices[id: id] == nil {
          // create a new Slice & add it to the Slices collection
          Model.shared.slices[id: id] = Slice(id)
          log("Slice \(id): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values to the Slice for parsing
        Task {
          await Model.shared.slices[id: id]?.parseProperties( Array(properties.dropFirst(1)) )
        }
        
      } else {
        // does it exist?
        if Model.shared.slices[id: id] != nil {
          // if the active Slice, update
          if Model.shared.activeSlice == Model.shared.slices[id: id] { Model.shared.activeSlice = nil }
          // YES, remove it
          remove(id)
        }
      }
    }
  }
  
  public static func setProperty(radio: Radio, id: SliceId, property: SliceProperty, value: Any) {
    switch property {
    case .active:                   sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .agcMode:                  sendCommand(radio, id, property, value)
    case .agcOffLevel:              sendCommand(radio, id, property, value)
    case .agcThreshold:             sendCommand(radio, id, property, Int(value as! Double))
    case .anfEnabled:               sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .anfLevel:                 sendCommand(radio, id, property, Int(value as! Double))
    case .apfEnabled:               sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .apfLevel:                 sendCommand(radio, id, property, Int(value as! Double))
    case .audioLevel:               sendCommand(radio, id, property, Int(value as! Double))
    case .audioMute:                sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .audioPan:                 sendCommand(radio, id, property, Int(value as! Double))
    case .daxChannel:               sendCommand(radio, id, property, value)
    case .daxTxEnabled:             sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .dfmPreDeEmphasisEnabled:  sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .digitalLowerOffset:       sendCommand(radio, id, property, value)
    case .digitalUpperOffset:       sendCommand(radio, id, property, value)
    case .diversityEnabled:         sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .filterHigh:               sendFilterCommand(radio, id, low: Model.shared.slices[id: id]!.filterLow, high: value)
    case .filterLow:                sendFilterCommand(radio, id, low: value, high: Model.shared.slices[id: id]!.filterHigh)
    case .fmDeviation:              sendCommand(radio, id, property, value)
    case .fmRepeaterOffset:         sendCommand(radio, id, property, value)
    case .fmToneBurstEnabled:       sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .fmToneFreq:               sendCommand(radio, id, property, value)
    case .fmToneMode:               sendCommand(radio, id, property, value)
    case .frequency:                sendTuneCommand(radio, id, value, autoPan: Model.shared.slices[id: id]!.autoPan)
    case .locked:                   sendLockCommand(radio, id, (value as! Bool) ? "lock" : "unlock")
    case .loopAEnabled:             sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .loopBEnabled:             sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .mode:                     sendCommand(radio, id, property, value)
    case .nbEnabled:                sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .nbLevel:                  sendCommand(radio, id, property, Int(value as! Double))
    case .nrEnabled:                sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .nrLevel:                  sendCommand(radio, id, property, Int(value as! Double))
    case .playbackEnabled:          sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .postDemodBypassEnabled:   sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .qskEnabled:               sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .recordEnabled:            sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .repeaterOffsetDirection:  sendCommand(radio, id, property, value)
    case .rfGain:                   sendCommand(radio, id, property, value)
    case .ritEnabled:               sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .ritOffset:                sendCommand(radio, id, property, value)
    case .rttyMark:                 sendCommand(radio, id, property, value)
    case .rttyShift:                sendCommand(radio, id, property, value)
    case .rxAnt:                    sendCommand(radio, id, property, value)
    case .sampleRate:               sendCommand(radio, id, property, value)
    case .squelchEnabled:           sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .squelchLevel:             sendCommand(radio, id, property, value)
    case .step:                     sendCommand(radio, id, property, value)
    case .stepList:                 sendCommand(radio, id, property, value)
    case .txEnabled:                sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .txAnt:                    sendCommand(radio, id, property, value)
    case .txOffsetFreq:             sendCommand(radio, id, property, value)
    case .wnbEnabled:               sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .wnbLevel:                 sendCommand(radio, id, property, Int(value as! Double))
    case .xitEnabled:               sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .xitOffset:                sendCommand(radio, id, property, value)
    
    case .clientHandle,.daxClients,.detached:                   break
    case .diversityChild,.diversityIndex,.diversityParent:      break
    case .ghost,.inUse,.modeList,.nr2,.owner:                   break
    case .panadapterId,.postDemodHigh,.postDemodLow:            break
    case .recordTime,.rxAntList,.sliceLetter,.txAntList,.wide:  break
    case .audioGain:                                            break
    }
    
    Task {
      switch property {
      case .nbEnabled, .nrEnabled, .anfEnabled, .wnbEnabled, .audioMute, .ritEnabled, .xitEnabled:
        await Model.shared.slices[id: id]?.parseProperties( [(key: property.rawValue, value: "\((value as! Bool).as1or0)")] )
      
//      case .frequency
//        await Model.shared.slices[id: id]?.parseProperties( [(key: property.rawValue, value: "\(value)")] )
        
      default:
        await Model.shared.slices[id: id]?.parseProperties( [(key: property.rawValue, value: "\(value)")] )
      }
    }
  }
  
  /// Remove the specified Slice
  /// - Parameter id:     a SliceId
  public static func remove(_ id: SliceId) {
    Model.shared.slices.remove(id: id)
    log("Slice \(id): removed", .debug, #function, #file, #line)  }
  
  /// Remove all Slices
  public static func removeAll() {
    for slice in Model.shared.slices {
      remove(slice.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Parse Slice key/value pairs
  /// - Parameter properties: a KeyValuesArray
  @MainActor private func parseProperties(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = SliceProperty(rawValue: property.key) else {
        // log it and ignore the Key
        log("Slice \(id) unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // Known keys, in alphabetical order
      switch token {
        
      case .active:                   active = property.value.bValue
      case .agcMode:                  agcMode = property.value
      case .agcOffLevel:              agcOffLevel = property.value.iValue
      case .agcThreshold:             agcThreshold = property.value.dValue
      case .anfEnabled:               anfEnabled = property.value.bValue
      case .anfLevel:                 anfLevel = property.value.dValue
      case .apfEnabled:               apfEnabled = property.value.bValue
      case .apfLevel:                 apfLevel = property.value.iValue
      case .audioGain:                audioGain = property.value.dValue
      case .audioLevel:               audioGain = property.value.dValue
      case .audioMute:                audioMute = property.value.bValue
      case .audioPan:                 audioPan = property.value.dValue
      case .clientHandle:             clientHandle = property.value.handle ?? 0
      case .daxChannel:
        if daxChannel != 0 && property.value.iValue == 0 {
          // remove this slice from the AudioStream it was using
          //          if let daxRxAudioStream = radio.findDaxRxAudioStream(with: daxChannel) { daxRxAudioStream.slice = nil }
        }
        Model.shared.slices[id: id]!.daxChannel = property.value.iValue
      case .daxTxEnabled:             daxTxEnabled = property.value.bValue
      case .detached:                 detached = property.value.bValue
      case .dfmPreDeEmphasisEnabled:  dfmPreDeEmphasisEnabled = property.value.bValue
      case .digitalLowerOffset:       digitalLowerOffset = property.value.iValue
      case .digitalUpperOffset:       digitalUpperOffset = property.value.iValue
      case .diversityEnabled:         diversityEnabled = property.value.bValue
      case .diversityChild:           diversityChild = property.value.bValue
      case .diversityIndex:           diversityIndex = property.value.iValue
      case .filterHigh:               filterHigh = property.value.iValue
      case .filterLow:                filterLow = property.value.iValue
      case .fmDeviation:              fmDeviation = property.value.iValue
      case .fmRepeaterOffset:         fmRepeaterOffset = property.value.fValue
      case .fmToneBurstEnabled:       fmToneBurstEnabled = property.value.bValue
      case .fmToneMode:               fmToneMode = property.value
      case .fmToneFreq:               fmToneFreq = property.value.fValue
      case .frequency:                frequency = property.value.mhzToHz
      case .inUse:                    inUse = property.value.bValue
      case .locked:                   locked = property.value.bValue
      case .loopAEnabled:             loopAEnabled = property.value.bValue
      case .loopBEnabled:             loopBEnabled = property.value.bValue
      case .mode:                     mode = property.value.uppercased() ; filters = updateFilters(mode)
      case .modeList:                 modeList = property.value
      case .nbEnabled:                nbEnabled = property.value.bValue
      case .nbLevel:                  nbLevel = property.value.dValue
      case .nrEnabled:                nrEnabled = property.value.bValue
      case .nrLevel:                  nrLevel = property.value.dValue
      case .nr2:                      nr2 = property.value.iValue
      case .owner:                    nr2 = property.value.iValue
      case .panadapterId:             panadapterId = property.value.streamId ?? 0
      case .playbackEnabled:          playbackEnabled = (property.value == "enabled") || (property.value == "1")
      case .postDemodBypassEnabled:   postDemodBypassEnabled = property.value.bValue
      case .postDemodLow:             postDemodLow = property.value.iValue
      case .postDemodHigh:            postDemodHigh = property.value.iValue
      case .qskEnabled:               qskEnabled = property.value.bValue
      case .recordEnabled:            recordEnabled = property.value.bValue
      case .repeaterOffsetDirection:  repeaterOffsetDirection = property.value
      case .rfGain:                   rfGain = property.value.iValue
      case .ritOffset:                ritOffset = property.value.iValue
      case .ritEnabled:               ritEnabled = property.value.bValue
      case .rttyMark:                 rttyMark = property.value.iValue
      case .rttyShift:                rttyShift = property.value.iValue
      case .rxAnt:                    rxAnt = property.value
      case .rxAntList:                rxAntList = property.value.list
      case .sampleRate:               sampleRate = property.value.iValue         // FIXME: ????? not in v3.2.15 source code
      case .sliceLetter:              sliceLetter = property.value
      case .squelchEnabled:           squelchEnabled = property.value.bValue
      case .squelchLevel:             squelchLevel = property.value.iValue
      case .step:                     step = property.value.iValue
      case .stepList:                 stepList = property.value
      case .txEnabled:                txEnabled = property.value.bValue
      case .txAnt:                    txAnt = property.value
      case .txAntList:                txAntList = property.value.list
      case .txOffsetFreq:             txOffsetFreq = property.value.fValue
      case .wide:                     wide = property.value.bValue
      case .wnbEnabled:               wnbEnabled = property.value.bValue
      case .wnbLevel:                 wnbLevel = property.value.dValue
      case .xitOffset:                xitOffset = property.value.iValue
      case .xitEnabled:               xitEnabled = property.value.bValue
        
        // the following are ignored here
      case .daxClients, .diversityParent, .recordTime: break
      case .ghost:                    break
      }
    }
    // is it initialized?
    if initialized == false && panadapterId != 0 && frequency != 0 && mode != "" {
      // NO, it is now
      initialized = true
      log("Slice \(id): initialized frequency = \( Model.shared.slices[id: id]!.frequency), panadapter = \( Model.shared.slices[id: id]!.panadapterId.hex)", .debug, #function, #file, #line)
    }
  }
  
  /// Send a command to Set a Slice property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Slice
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: SliceId, _ token: SliceProperty, _ value: Any) {
    radio.send("slice set " + "\(id) " + token.rawValue + "=\(value)")
  }
  
  private static func sendFilterCommand(_ radio: Radio, _ id: SliceId, low: Any, high: Any) {
    radio.send("filt \(id) " + "\(low) \(high)")
  }
  
  public static func sendTuneCommand(_ radio: Radio, _ id: SliceId, _ value: Any, autoPan: Bool = false) {
    radio.send("slice tune " + "\(id) \(value) " + "autopan" + "=\(autoPan.as1or0)")
  }
  /// Set a Slice Lock property on the Radio
  /// - Parameters:
  ///   - value:      the new value (lock / unlock)
  public static func sendLockCommand(_ radio: Radio, _ id: SliceId, _ lockState: String) {
    radio.send("slice " + lockState + " \(id)")
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Set the default Filter widths
  /// - Parameters:
  ///   - mode:       demod mode
  ///
  private func setupDefaultFilters(_ mode: String) {
    if let modeValue = Mode(rawValue: mode) {
      switch modeValue {
        
      case .CW:
        filterLow = 450
        filterHigh = 750
      case .RTTY:
        filterLow = -285
        filterHigh = 115
      case .AM, .SAM:
        filterLow = -3_000
        filterHigh = 3_000
      case .FM, .NFM, .DFM:
        filterLow = -8_000
        filterHigh = 8_000
      case .LSB, .DIGL:
        filterLow = -2_400
        filterHigh = -300
      case .USB, .DIGU:
        filterLow = 300
        filterHigh = 2_400
      }
    }
  }
  private func updateFilters(_ mode: String) -> [(value: Int, label: String)] {
    var filterTuples = [(value: Int, label: String)]()
    let modeFilters = Slice.filterDefaults[mode]!
    for filter in modeFilters {
      let tuple = (filter, filterLabel(filter))
      filterTuples.append(tuple)
    }
    return filterTuples
  }
    
  func filterLabel(_ value: Int) -> String {
    var label = "-"
    switch value {
    case 1_000...:      label = String(format: "%2.1fk", Float(value)/1000.0)
    case 1..<1_000:     label = String(format: "%3d", value)
    default:            label = "-"
    }
    return label
  }
  
}
