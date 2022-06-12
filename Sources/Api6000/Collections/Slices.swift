//
//  Slices.swift
//  
//
//  Created by Douglas Adams on 6/11/22.
//

import Foundation
import IdentifiedCollections

import Shared

public actor Slices {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public enum SliceToken : String {
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
  // MARK: - Private properties
  
  private var _slices = IdentifiedArrayOf<Slice>()
  
  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = Slices()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func add(_ slice: Slice) {
    _slices[id: slice.id] = slice
    updateModel()
  }
  
  public func exists(id: SliceId) -> Bool {
    _slices[id: id] != nil
  }
  
  /// Parse a Slice status message
  /// - Parameters:
  ///   - keyValues:      a KeyValuesArray
  ///   - inUse:          false = "to be deleted"
  public func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id
    if let id = properties[0].key.objectId {
      // is the object in use?
      if inUse {
        // YES, does it exist?
        if !exists(id: id) {
          // create a new Slice & add it to the Slices collection
          add( Slice(id) )
          log("Slice \(id): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values to the Slice for parsing
        parseProperties( id, Array(properties.dropFirst(1)) )
        
      } else {
        remove(id)
      }
    }
  }

  /// Remove a Slice
  /// - Parameter id:   a Slice Id
  public func remove(_ id: SliceId)  {
   _slices.remove(id: id)
    log("Slice \(id.hex): removed", .debug, #function, #file, #line)

    updateModel()
  }
  
  /// Remove all Slices
  public func removeAll()  {
    for slice in _slices {
      remove(slice.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Parse Slice key/value pairs
  /// - Parameter properties: a KeyValuesArray
  private func parseProperties(_ id: SliceId, _ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = SliceToken(rawValue: property.key) else {
        // log it and ignore the Key
        log("Slice \(id) unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // Known keys, in alphabetical order
      switch token {
        
      case .active:                   _slices[id: id]?.active = property.value.bValue
      case .agcMode:                  _slices[id: id]?.agcMode = property.value
      case .agcOffLevel:              _slices[id: id]?.agcOffLevel = property.value.iValue
      case .agcThreshold:             _slices[id: id]?.agcThreshold = property.value.dValue
      case .anfEnabled:               _slices[id: id]?.anfEnabled = property.value.bValue
      case .anfLevel:                 _slices[id: id]?.anfLevel = property.value.iValue
      case .apfEnabled:               _slices[id: id]?.apfEnabled = property.value.bValue
      case .apfLevel:                 _slices[id: id]?.apfLevel = property.value.iValue
      case .audioGain:                _slices[id: id]?.audioGain = property.value.dValue
      case .audioLevel:               _slices[id: id]?.audioGain = property.value.dValue
      case .audioMute:                _slices[id: id]?.audioMute = property.value.bValue
      case .audioPan:                 _slices[id: id]?.audioPan = property.value.dValue
      case .clientHandle:             _slices[id: id]?.clientHandle = property.value.handle ?? 0
      case .daxChannel:
        if _slices[id: id]?.daxChannel != 0 && property.value.iValue == 0 {
          // remove this slice from the AudioStream it was using
          //          if let daxRxAudioStream = radio.findDaxRxAudioStream(with: daxChannel) { daxRxAudioStream.slice = nil }
        }
        _slices[id: id]!.daxChannel = property.value.iValue
      case .daxTxEnabled:             _slices[id: id]?.daxTxEnabled = property.value.bValue
      case .detached:                 _slices[id: id]?.detached = property.value.bValue
      case .dfmPreDeEmphasisEnabled:  _slices[id: id]?.dfmPreDeEmphasisEnabled = property.value.bValue
      case .digitalLowerOffset:       _slices[id: id]?.digitalLowerOffset = property.value.iValue
      case .digitalUpperOffset:       _slices[id: id]?.digitalUpperOffset = property.value.iValue
      case .diversityEnabled:         _slices[id: id]?.diversityEnabled = property.value.bValue
      case .diversityChild:           _slices[id: id]?.diversityChild = property.value.bValue
      case .diversityIndex:           _slices[id: id]?.diversityIndex = property.value.iValue
      case .filterHigh:               _slices[id: id]?.filterHigh = property.value.iValue
      case .filterLow:                _slices[id: id]?.filterLow = property.value.iValue
      case .fmDeviation:              _slices[id: id]?.fmDeviation = property.value.iValue
      case .fmRepeaterOffset:         _slices[id: id]?.fmRepeaterOffset = property.value.fValue
      case .fmToneBurstEnabled:       _slices[id: id]?.fmToneBurstEnabled = property.value.bValue
      case .fmToneMode:               _slices[id: id]?.fmToneMode = property.value
      case .fmToneFreq:               _slices[id: id]?.fmToneFreq = property.value.fValue
      case .frequency:                _slices[id: id]?.frequency = property.value.mhzToHz
      case .inUse:                    _slices[id: id]?.inUse = property.value.bValue
      case .locked:                   _slices[id: id]?.locked = property.value.bValue
      case .loopAEnabled:             _slices[id: id]?.loopAEnabled = property.value.bValue
      case .loopBEnabled:             _slices[id: id]?.loopBEnabled = property.value.bValue
      case .mode:                     _slices[id: id]?.mode = property.value.uppercased()
      case .modeList:                 _slices[id: id]?.modeList = property.value
      case .nbEnabled:                _slices[id: id]?.nbEnabled = property.value.bValue
      case .nbLevel:                  _slices[id: id]?.nbLevel = property.value.iValue
      case .nrEnabled:                _slices[id: id]?.nrEnabled = property.value.bValue
      case .nrLevel:                  _slices[id: id]?.nrLevel = property.value.iValue
      case .nr2:                      _slices[id: id]?.nr2 = property.value.iValue
      case .owner:                    _slices[id: id]?.nr2 = property.value.iValue
      case .panadapterId:             _slices[id: id]?.panadapterId = property.value.streamId ?? 0
      case .playbackEnabled:          _slices[id: id]?.playbackEnabled = (property.value == "enabled") || (property.value == "1")
      case .postDemodBypassEnabled:   _slices[id: id]?.postDemodBypassEnabled = property.value.bValue
      case .postDemodLow:             _slices[id: id]?.postDemodLow = property.value.iValue
      case .postDemodHigh:            _slices[id: id]?.postDemodHigh = property.value.iValue
      case .qskEnabled:               _slices[id: id]?.qskEnabled = property.value.bValue
      case .recordEnabled:            _slices[id: id]?.recordEnabled = property.value.bValue
      case .repeaterOffsetDirection:  _slices[id: id]?.repeaterOffsetDirection = property.value
      case .rfGain:                   _slices[id: id]?.rfGain = property.value.iValue
      case .ritOffset:                _slices[id: id]?.ritOffset = property.value.iValue
      case .ritEnabled:               _slices[id: id]?.ritEnabled = property.value.bValue
      case .rttyMark:                 _slices[id: id]?.rttyMark = property.value.iValue
      case .rttyShift:                _slices[id: id]?.rttyShift = property.value.iValue
      case .rxAnt:                    _slices[id: id]?.rxAnt = property.value
      case .rxAntList:                _slices[id: id]?.rxAntList = property.value.list
      case .sampleRate:               _slices[id: id]?.sampleRate = property.value.iValue         // FIXME: ????? not in v3.2.15 source code
      case .sliceLetter:              _slices[id: id]?.sliceLetter = property.value
      case .squelchEnabled:           _slices[id: id]?.squelchEnabled = property.value.bValue
      case .squelchLevel:             _slices[id: id]?.squelchLevel = property.value.iValue
      case .step:                     _slices[id: id]?.step = property.value.iValue
      case .stepList:                 _slices[id: id]?.stepList = property.value
      case .txEnabled:                _slices[id: id]?.txEnabled = property.value.bValue
      case .txAnt:                    _slices[id: id]?.txAnt = property.value
      case .txAntList:                _slices[id: id]?.txAntList = property.value.list
      case .txOffsetFreq:             _slices[id: id]?.txOffsetFreq = property.value.fValue
      case .wide:                     _slices[id: id]?.wide = property.value.bValue
      case .wnbEnabled:               _slices[id: id]?.wnbEnabled = property.value.bValue
      case .wnbLevel:                 _slices[id: id]?.wnbLevel = property.value.iValue
      case .xitOffset:                _slices[id: id]?.xitOffset = property.value.iValue
      case .xitEnabled:               _slices[id: id]?.xitEnabled = property.value.bValue
        
        // the following are ignored here
      case .daxClients, .diversityParent, .recordTime: break
      case .ghost:                    break
      }
    }
    // is it initialized?
    if _slices[id: id]?.initialized == false && _slices[id: id]?.panadapterId != 0 && _slices[id: id]?.frequency != 0 && _slices[id: id]?.mode != "" {
      // NO, it is now
      _slices[id: id]?.initialized = true
      log("Slice \(id): initialized frequency = \( _slices[id: id]!.frequency), panadapter = \( _slices[id: id]!.panadapterId.hex)", .debug, #function, #file, #line)
    }
    updateModel()
  }

  private func updateModel() {
    Task {
      await Model.shared.setSlices(_slices)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         a Slice Id
  ///   - property:   a Slice Token
  ///   - value:      the new value
  public static nonisolated func setProperty(radio: Radio, _ id: SliceId, property: SliceToken, value: Any) {
    switch property {
    case .active:                   sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .agcMode:                  sendCommand(radio, id, property, value)
    case .agcOffLevel:              sendCommand(radio, id, property, value)
    case .agcThreshold:             sendCommand(radio, id, property, value)
    case .anfEnabled:               sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .anfLevel:                 sendCommand(radio, id, property, value)
    case .apfEnabled:               sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .apfLevel:                 sendCommand(radio, id, property, value)
    case .audioLevel:               sendCommand(radio, id, property, value)
    case .audioMute:                sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .audioPan:                 sendCommand(radio, id, property, Int(value as! Double))
    case .daxChannel:               sendCommand(radio, id, property, value)
    case .daxTxEnabled:             sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .dfmPreDeEmphasisEnabled:  sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .digitalLowerOffset:       sendCommand(radio, id, property, value)
    case .digitalUpperOffset:       sendCommand(radio, id, property, value)
    case .diversityEnabled:         sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .fmDeviation:              sendCommand(radio, id, property, value)
    case .fmRepeaterOffset:         sendCommand(radio, id, property, value)
    case .fmToneBurstEnabled:       sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .fmToneFreq:               sendCommand(radio, id, property, value)
    case .fmToneMode:               sendCommand(radio, id, property, value)
    case .loopAEnabled:             sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .loopBEnabled:             sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .mode:                     sendCommand(radio, id, property, value)
    case .nbEnabled:                sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .nbLevel:                  sendCommand(radio, id, property, value)
    case .nrEnabled:                sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .nrLevel:                  sendCommand(radio, id, property, value)
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
    case .wnbLevel:                 sendCommand(radio, id, property, value)
    case .xitEnabled:               sendCommand(radio, id, property, (value as! Bool).as1or0)
    case .xitOffset:                sendCommand(radio, id, property, value)
    
    case .clientHandle,.daxClients,.detached:                   break
    case .diversityChild,.diversityIndex,.diversityParent:      break
    case .ghost,.inUse,.modeList,.nr2,.owner:                   break
    case .panadapterId,.postDemodHigh,.postDemodLow:            break
    case .recordTime,.rxAntList,.sliceLetter,.txAntList,.wide:  break
    case .audioGain:                                            break
    case .locked:                                               break
    case .filterLow:                                            break
    case .filterHigh:                                           break
    case .frequency:                                            break
    }
  }

  private static nonisolated func sendFilterCommand(_ radio: Radio, _ id: SliceId, low: Any, high: Any) {
    radio.send("filt \(id) " + "\(low) \(high)")
  }

  public static nonisolated func sendTuneCommand(_ radio: Radio, _ id: SliceId, _ value: Any, autoPan: Bool = false) {
    radio.send("slice tune " + "\(id) \(value) " + "autopan" + "=\(autoPan.as1or0)")
  }
  /// Set a Slice Lock property on the Radio
  /// - Parameters:
  ///   - value:      the new value (lock / unlock)
  public static nonisolated func sendLockCommand(_ radio: Radio, _ id: SliceId, _ lockState: String) {
    radio.send("slice " + lockState + " \(id)")
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Send a command to Set a Slice property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Slice
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: SliceId, _ token: SliceToken, _ value: Any) {
    radio.send("slice set " + "\(id) " + token.rawValue + "=\(value)")
  }
}

// ----------------------------------------------------------------------------
// MARK: - Slice Struct

public struct Slice: Identifiable {
  // ----------------------------------------------------------------------------
  // MARK: - Static properties
  
  static let kMinOffset = -99_999      // frequency offset range
  static let kMaxOffset = 99_999
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: SliceId
  
  public var initialized: Bool = false
  public var autoPan: Bool = false
  public var clientHandle: Handle = 0
  public var daxClients: Int = 0
  public var daxTxEnabled: Bool = false
  public var detached: Bool = false
  public var diversityChild: Bool = false
  public var diversityIndex: Int = 0
  public var diversityParent: Bool = false
  public var inUse: Bool = false
  public var modeList = ""
  public var nr2: Int = 0
  public var owner: Int = 0
  public var panadapterId: PanadapterId = 0
  public var postDemodBypassEnabled: Bool = false
  public var postDemodHigh: Int = 0
  public var postDemodLow: Int = 0
  public var qskEnabled: Bool = false
  public var recordLength: Float = 0
  public var rxAntList = [AntennaPort]()
  public var sliceLetter: String?
  public var txAntList = [AntennaPort]()
  public var wide: Bool = false
  
  public var active: Bool = false
  public var agcMode: String = AgcMode.off.rawValue
  public var agcOffLevel: Int = 0
  public var agcThreshold: Double = 0
  public var anfEnabled: Bool = false
  public var anfLevel: Int = 0
  public var apfEnabled: Bool = false
  public var apfLevel: Int = 0
  public var audioGain: Double = 0
  public var audioMute: Bool = false
  public var audioPan: Double = 0
  public var daxChannel: Int = 0
  public var dfmPreDeEmphasisEnabled: Bool = false
  public var digitalLowerOffset: Int = 0
  public var digitalUpperOffset: Int = 0
  public var diversityEnabled: Bool = false
  public var filterHigh: Int = 0
  public var filterLow: Int = 0
  public var fmDeviation: Int = 0
  public var fmRepeaterOffset: Float = 0
  public var fmToneBurstEnabled: Bool = false
  public var fmToneFreq: Float = 0
  public var fmToneMode: String = ""
  public var frequency: Hz = 0
  public var locked: Bool = false
  public var loopAEnabled: Bool = false
  public var loopBEnabled: Bool = false
  public var mode: String = ""
  public var nbEnabled: Bool = false
  public var nbLevel: Int = 0
  public var nrEnabled: Bool = false
  public var nrLevel: Int = 0
  public var playbackEnabled: Bool = false
  public var recordEnabled: Bool = false
  public var repeaterOffsetDirection: String = ""
  public var rfGain: Int = 0
  public var ritEnabled: Bool = false
  public var ritOffset: Int = 0
  public var rttyMark: Int = 0
  public var rttyShift: Int = 0
  public var rxAnt: String = ""
  public var sampleRate: Int = 0
  public var step: Int = 0
  public var stepList: String = "1, 10, 50, 100, 500, 1000, 2000, 3000"
  public var squelchEnabled: Bool = false
  public var squelchLevel: Int = 0
  public var txAnt: String = ""
  public var txEnabled: Bool = false
  public var txOffsetFreq: Float = 0
  public var wnbEnabled: Bool = false
  public var wnbLevel: Int = 0
  public var xitEnabled: Bool = false
  public var xitOffset: Int = 0
  
  public var agcNames = AgcMode.names()
  public let daxChoices = Radio.kDaxChannels
  
  public enum Offset : String {
    case up
    case down
    case simplex
  }
  public enum AgcMode : String, CaseIterable {
    case off
    case slow
    case med
    case fast
    
    static func names() -> [String] {
      return [AgcMode.off.rawValue, AgcMode.slow.rawValue, AgcMode.med.rawValue, AgcMode.fast.rawValue]
    }
  }
  public enum Mode : String, CaseIterable {
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
  
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: SliceId) {
    self.id = id
    // set filterLow & filterHigh to default values
    setupDefaultFilters(mode)
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Set the default Filter widths
  /// - Parameters:
  ///   - mode:       demod mode
  ///
  private mutating func setupDefaultFilters(_ mode: String) {
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
}
