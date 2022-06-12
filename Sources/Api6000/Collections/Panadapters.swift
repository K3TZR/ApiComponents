//
//  Panadapters.swift
//  
//
//  Created by Douglas Adams on 6/10/22.
//

import Foundation
import IdentifiedCollections

import Shared
import Vita

public actor Panadapters {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public enum PanadapterToken : String {
    // on Panadapter
    case antList                    = "ant_list"
    case average
    case band
    case bandwidth
    case bandZoomEnabled            = "band_zoom"
    case center
    case clientHandle               = "client_handle"
    case daxIq                      = "daxiq"
    case daxIqChannel               = "daxiq_channel"
    case fps
    case loopAEnabled               = "loopa"
    case loopBEnabled               = "loopb"
    case maxBw                      = "max_bw"
    case maxDbm                     = "max_dbm"
    case minBw                      = "min_bw"
    case minDbm                     = "min_dbm"
    case preamp                     = "pre"
    case rfGain                     = "rfgain"
    case rxAnt                      = "rxant"
    case segmentZoomEnabled         = "segment_zoom"
    case waterfallId                = "waterfall"
    case weightedAverageEnabled     = "weighted_average"
    case wide
    case wnbEnabled                 = "wnb"
    case wnbLevel                   = "wnb_level"
    case wnbUpdating                = "wnb_updating"
    case xPixels                    = "x_pixels"
    case xvtrLabel                  = "xvtr"
    case yPixels                    = "y_pixels"
    // ignored by Panadapter
    case available
    case capacity
    case daxIqRate                  = "daxiq_rate"
    // not sent in status messages
    case n1mmSpectrumEnable         = "n1mm_spectrum_enable"
    case n1mmAddress                = "n1mm_address"
    case n1mmPort                   = "n1mm_port"
    case n1mmRadio                  = "n1mm_radio"
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _panadapters = IdentifiedArrayOf<Panadapter>()
  
  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = Panadapters()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methds
  
  public func add(_ panadapter: Panadapter) {
    _panadapters[id: panadapter.id] = panadapter
    updateModel()
  }
  
  public func exists(id:PanadapterId) -> Bool {
    _panadapters[id: id] != nil
  }
  
  /// Parse a Panadapter status message
  /// - Parameters:
  ///   - properties:     a KeyValuesArray of Panadapter properties
  ///   - inUse:          false = "to be deleted"
  public func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) async {
    // Note: Tnf does not send status on removal
    
    // get the Id
    if let id = properties[1].key.streamId {
      // is the object in use?
      if inUse {
        // YES, does it exist?
        if !exists(id: id) {
          // NO, create a new Panadapter
          //          Model.shared.tnfs[id: id] = Tnf(id)
          add( Panadapter(id) )
          log("Panadapter \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values to the Panadapter for parsing
        //        Model.shared.tnfs[id: id]?.parseProperties( Array(properties.dropFirst(1)) )
        parseProperties( id, Array(properties.dropFirst(2)) )
      } else {
        remove(id)
      }
    }
  }

  /// Remove a Panadapter
  /// - Parameter id:   a Panadapter Id
  public func remove(_ id: PanadapterId)  {
    _panadapters.remove(id: id)
    log("Panadapter \(id.hex): removed", .debug, #function, #file, #line)

    updateModel()
  }
  
  /// Remove all Panadapters
  public func removeAll()  {
    for panadapter in _panadapters {
      remove(panadapter.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methds
  
  /// Parse Panadapter key/value pairs
  /// - Parameter properties: a KeyValuesArray
  private func parseProperties(_ id: PanadapterId, _ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = PanadapterToken(rawValue: property.key) else {
        // log it and ignore the Key
        log("Tnf \(id): unknown token \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // Known keys, in alphabetical order
      switch token {
      case .antList:                _panadapters[id: id]?.antList = property.value.list
      case .average:                _panadapters[id: id]?.average = property.value.iValue
      case .band:                   _panadapters[id: id]?.band = property.value
      case .bandwidth:              _panadapters[id: id]?.bandwidth = property.value.mhzToHz
      case .bandZoomEnabled:        _panadapters[id: id]?.bandZoomEnabled = property.value.bValue
      case .center:                 _panadapters[id: id]?.center = property.value.mhzToHz
      case .clientHandle:           _panadapters[id: id]?.clientHandle = property.value.handle ?? 0
      case .daxIq:                  _panadapters[id: id]?.daxIqChannel = property.value.iValue
      case .daxIqChannel:           _panadapters[id: id]?.daxIqChannel = property.value.iValue
      case .fps:                    _panadapters[id: id]?.fps = property.value.iValue
      case .loopAEnabled:           _panadapters[id: id]?.loopAEnabled = property.value.bValue
      case .loopBEnabled:           _panadapters[id: id]?.loopBEnabled = property.value.bValue
      case .maxBw:                  _panadapters[id: id]?.maxBw = property.value.mhzToHz
      case .maxDbm:                 _panadapters[id: id]?.maxDbm = property.value.cgValue
      case .minBw:                  _panadapters[id: id]?.minBw = property.value.mhzToHz
      case .minDbm:                 _panadapters[id: id]?.minDbm = property.value.cgValue
      case .preamp:                 _panadapters[id: id]?.preamp = property.value
      case .rfGain:                 _panadapters[id: id]?.rfGain = property.value.iValue
      case .rxAnt:                  _panadapters[id: id]?.rxAnt = property.value
      case .segmentZoomEnabled:     _panadapters[id: id]?.segmentZoomEnabled = property.value.bValue
      case .waterfallId:            _panadapters[id: id]?.waterfallId = property.value.streamId ?? 0
      case .wide:                   _panadapters[id: id]?.wide = property.value.bValue
      case .weightedAverageEnabled: _panadapters[id: id]?.weightedAverageEnabled = property.value.bValue
      case .wnbEnabled:             _panadapters[id: id]?.wnbEnabled = property.value.bValue
      case .wnbLevel:               _panadapters[id: id]?.wnbLevel = property.value.iValue
      case .wnbUpdating:            _panadapters[id: id]?.wnbUpdating = property.value.bValue
      case .xvtrLabel:              _panadapters[id: id]?.xvtrLabel = property.value
      
      case .available, .capacity, .daxIqRate, .xPixels, .yPixels:     break // ignored by Panadapter
      case .n1mmSpectrumEnable, .n1mmAddress, .n1mmPort, .n1mmRadio:  break // not sent in status messages
      }
    }
    // is it initialized?∫
    if _panadapters[id: id]?.initialized == false && _panadapters[id: id]?.center != 0 && _panadapters[id: id]?.bandwidth != 0 && (_panadapters[id: id]?.minDbm != 0.0 || _panadapters[id: id]?.maxDbm != 0.0) {
      // NO, it is now
      _panadapters[id: id]?.initialized = true
      log("Panadapter \(id.hex): initialized center = \(_panadapters[id: id]?.center.hzToMhz), bandwidth = \(_panadapters[id: id]?.bandwidth.hzToMhz)", .debug, #function, #file, #line)
    }
    updateModel()
  }
  
  private func updateModel() {
    Task {
      await Model.shared.setPanadapters(_panadapters)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methds
  
  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         a PanadapterId Id
  ///   - property:   a PanadapterId Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, _ id: PanadapterId, _ property: PanadapterToken, _ value: Any) {
    switch property {
    case .antList:                sendCommand( radio, id, .antList, value)
    case .average:                sendCommand( radio, id, .average, value)
    case .band:                   sendCommand( radio, id, .band, value)
    case .bandwidth:              sendCommand( radio, id, .bandwidth, (value as! Hz).hzToMhz)
    case .bandZoomEnabled:        sendCommand( radio, id, .bandZoomEnabled, (value as! Bool).as1or0)
    case .center:                 sendCommand( radio, id, .center, (value as! Hz).hzToMhz)
    case .clientHandle:           sendCommand( radio, id, .clientHandle, value)
    case .daxIq:                  sendCommand( radio, id, .daxIqChannel, value)
    case .daxIqChannel:           sendCommand( radio, id, .daxIqChannel, value)
    case .fps:                    sendCommand( radio, id, .fps, value)
    case .loopAEnabled:           sendCommand( radio, id, .loopAEnabled, (value as! Bool).as1or0)
    case .loopBEnabled:           sendCommand( radio, id, .loopBEnabled, (value as! Bool).as1or0)
    case .maxBw:                  sendCommand( radio, id, .maxBw, (value as! Hz).hzToMhz)
    case .maxDbm:                 sendCommand( radio, id, .maxDbm, value)
    case .minBw:                  sendCommand( radio, id, .minBw, (value as! Hz).hzToMhz)
    case .minDbm:                 sendCommand( radio, id, .minDbm, value)
    case .preamp:                 sendCommand( radio, id, .preamp, value)
    case .rfGain:                 sendCommand( radio, id, .rfGain, value)
    case .rxAnt:                  sendCommand( radio, id, .rxAnt, value)
    case .segmentZoomEnabled:     sendCommand( radio, id, .segmentZoomEnabled, (value as! Bool).as1or0)
    case .waterfallId:            sendCommand( radio, id, .waterfallId, value)
    case .wide:                   sendCommand( radio, id, .wide, (value as! Bool).as1or0)
    case .weightedAverageEnabled: sendCommand( radio, id, .weightedAverageEnabled, (value as! Bool).as1or0)
    case .wnbEnabled:             sendCommand( radio, id, .wnbEnabled, (value as! Bool).as1or0)
    case .wnbLevel:               sendCommand( radio, id, .wnbLevel, value)
    case .wnbUpdating:            sendCommand( radio, id, .wnbUpdating, (value as! Bool).as1or0)
    case .xPixels:                sendCommand( radio, id, "xpixels", value)
    case .xvtrLabel:              sendCommand( radio, id, .xvtrLabel, value)
    case .yPixels:                sendCommand( radio, id, "ypixels", value)
    
    case .available, .capacity, .daxIqRate:                         break // ignored by Panadapter
    case .n1mmSpectrumEnable, .n1mmAddress, .n1mmPort, .n1mmRadio:  break // not sent in status messages
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private Static methds
  
  /// Send a command to Set a Panadapter property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Waterfall
  ///   - token:      the parse token
  ///   - value:      the new value
  private static nonisolated func sendCommand(_ radio: Radio, _ id: PanadapterId, _ token: PanadapterToken, _ value: Any) {
      radio.send("display panafall set " + "\(id.hex) " + token.rawValue + "=\(value)")
  }

  /// Send a command to Set a Panadapter property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Waterfall
  ///   - token:      a String used as the token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: PanadapterId, _ token: String, _ value: Any) {
      // NOTE: commands use this format when the Token received does not match the Token sent
      //      e.g. see EqualizerCommands.swift where "63hz" is received vs "63Hz" must be sent
      radio.send("display panafall set " + "\(id.hex) " + token + "=\(value)")
  }
}

// ----------------------------------------------------------------------------
// MARK: - Panadapter Struct

public struct Panadapter: Identifiable {
  // ----------------------------------------------------------------------------
  // MARK: - Static properties
  
  static let kMaxBins = 5120
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: PanadapterId
  
  public var initialized: Bool = false
  public var isStreaming: Bool = false
  public var antList = [String]()
  public var clientHandle: Handle = 0
  public var dbmValues = [LegendValue]()
  public var delegate: StreamHandler?
  public var fillLevel: Int = 0
  public var freqValues = [LegendValue]()
  public var maxBw: Hz = 0
  public var minBw: Hz = 0
  public var preamp = ""
  public var rfGainHigh = 0
  public var rfGainLow = 0
  public var rfGainStep = 0
  public var rfGainValues = ""
  public var waterfallId: UInt32 = 0
  public var wide = false
  public var wnbUpdating = false
  public var xvtrLabel = ""
  
  public var average: Int = 0
  public var band: String = ""
  // FIXME: Where does autoCenter come from?
  public var bandwidth: Hz = 0
  public var bandZoomEnabled: Bool  = false
  public var center: Hz = 0
  public var daxIqChannel: Int = 0
  public var fps: Int = 0
  public var loggerDisplayEnabled: Bool = false
  public var loggerDisplayIpAddress: String = ""
  public var loggerDisplayPort: Int = 0
  public var loggerDisplayRadioNumber: Int = 0
  public var loopAEnabled: Bool = false
  public var loopBEnabled: Bool = false
  public var maxDbm: CGFloat = 0
  public var minDbm: CGFloat = 0
  public var rfGain: Int = 0
  public var rxAnt: String = ""
  public var segmentZoomEnabled: Bool = false
  public var weightedAverageEnabled: Bool = false
  public var wnbEnabled: Bool = false
  public var wnbLevel: Int = 0
  public var xPixels: CGFloat = 0
  public var yPixels: CGFloat = 0
  
  
  public struct LegendValue: Identifiable {
    public var id: CGFloat         // relative position 0...1
    public var label: String       // value to display
    public var value: CGFloat      // actual value
    public var lineCount: CGFloat
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let daxIqChoices = Radio.kDaxIqChannels
  static var q = DispatchQueue(label: "PanadapterSequenceQ")
  private var _expectedFrameNumber = -1
  private var _droppedPackets = 0
  private var _accumulatedBins = 0
    
  // ----------------------------------------------------------------------------
  // MARK: - Internal types
  
 private struct PayloadHeader {      // struct to mimic payload layout
    var startingBinNumber: UInt16
    var segmentBinCount: UInt16
    var binSize: UInt16
    var frameBinCount: UInt16
    var frameNumber: UInt32
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  @Atomic(0, q) private var index: Int

  private let _numberOfFrames = 16
  private var _frames = [PanadapterFrame]()
  private var _suppress = false
  
  private var _dbmStep: CGFloat = 10
  private var _dbmFormat = "%3.0f"
  private var _freqStep: CGFloat = 10_000
  private var _freqFormat = "%2.3f"
  
  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: PanadapterId) {
    self.id = id
    
    // allocate dataframes
    for _ in 0..<_numberOfFrames {
      _frames.append(PanadapterFrame(frameSize: Panadapter.kMaxBins))
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Process the Reply to an Rf Gain Info command, reply format: <value>,<value>,...<value>
  /// - Parameters:
  ///   - seqNum:         the Sequence Number of the original command
  ///   - responseValue:  the response value
  ///   - reply:          the reply
  public func rfGainReplyHandler(_ command: String, sequenceNumber: SequenceNumber, responseValue: String, reply: String) {
    // Anything other than 0 is an error
    guard responseValue == Shared.kNoError else {
      // log it and ignore the Reply
      log("Panadapter, non-zero reply: \(command), \(responseValue), \(flexErrorString(errorCode: responseValue))", .warning, #function, #file, #line)
      return
    }
    // parse out the values
    let rfGainInfo = reply.valuesArray( delimiter: "," )
    Model.shared.panadapters[id: id]!.rfGainLow = rfGainInfo[0].iValue
    Model.shared.panadapters[id: id]!.rfGainHigh = rfGainInfo[1].iValue
    Model.shared.panadapters[id: id]!.rfGainStep = rfGainInfo[2].iValue
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  /// Process the Panadapter Vita struct
  ///      The payload of the incoming Vita struct is converted to a PanadapterFrame and
  ///      passed to the Panadapter Stream Handler
  ///
  /// - Parameters:
  ///   - vita:        a Vita struct
  public mutating func vitaProcessor(_ vita: Vita, _ testMode: Bool = false) {
    if isStreaming == false {
      isStreaming = true
      // log the start of the stream
      log("Panadapter stream \(vita.streamId.hex): started", .info, #function, #file, #line)
    }
    // NO, Bins are just beyond the payload
    let byteOffsetToBins = MemoryLayout<PayloadHeader>.size
    
    vita.payloadData.withUnsafeBytes { ptr in
      
      // map the payload to the Payload struct
      let hdr = ptr.bindMemory(to: PayloadHeader.self)
      
      let startingBinNumber = Int(CFSwapInt16BigToHost(hdr[0].startingBinNumber))
      let segmentBinCount = Int(CFSwapInt16BigToHost(hdr[0].segmentBinCount))
      let frameBinCount = Int(CFSwapInt16BigToHost(hdr[0].frameBinCount))
      let frameNumber = Int(CFSwapInt32BigToHost(hdr[0].frameNumber))
      
      // validate the packet (could be incomplete at startup)
      if frameBinCount == 0 { return }
      if startingBinNumber + segmentBinCount > frameBinCount { return }
         
      // are we in the ApiTester?
      if testMode {
        // YES, are we waiting for the start of a frame?
        if _expectedFrameNumber == -1 {
          // YES, is it the start of a frame?
          if startingBinNumber == 0 {
            // YES, START OF A FRAME
            _expectedFrameNumber = frameNumber
          } else {
            // NO, NOT THE START OF A FRAME
            return
          }
        }
        // is it the expected frame?
        if _expectedFrameNumber == frameNumber {
          // IT IS THE EXPECTED FRAME, add its bins to the collection
          _accumulatedBins += segmentBinCount
          
          // is the frame complete?
          if _accumulatedBins == frameBinCount {
            // YES, expect the next frame
            _expectedFrameNumber += 1
            _accumulatedBins = 0
          }
          
        } else {
          // NOT THE EXPECTED FRAME, wait for the next start of frame
          log("Waterfall: missing frame(s), expected = \(_expectedFrameNumber), received = \(frameNumber)", .warning, #function, #file, #line)
          _expectedFrameNumber = -1
          _accumulatedBins = 0
          return
        }

      } else {
        
        if _expectedFrameNumber != frameNumber {
          _droppedPackets += (frameNumber - _expectedFrameNumber)
          log("Panadapter: missing frame(s), expected = \(_expectedFrameNumber), received = \(frameNumber), drop count = \(_droppedPackets)", .warning, #function, #file, #line)
          _expectedFrameNumber = frameNumber
        }
        
        vita.payloadData.withUnsafeBytes { ptr in
          // Swap the byte ordering of the data & place it in the bins
          for i in 0..<segmentBinCount {
            _frames[index].bins[i+startingBinNumber] = CFSwapInt16BigToHost( ptr.load(fromByteOffset: byteOffsetToBins + (2 * i), as: UInt16.self) )
          }
        }
        _accumulatedBins += segmentBinCount

        // is it a complete Frame?
        if _accumulatedBins == frameBinCount {
          _frames[index].frameBinCount = _accumulatedBins
          // YES, pass it to the delegate
          delegate?.streamHandler(_frames[index])
          
          // update the expected frame number & dataframe index
          _expectedFrameNumber += 1
          _accumulatedBins = 0
          $index.mutate { $0 += 1 ; $0 = $0 % _numberOfFrames }
        }
      }
    }
  }
}

/// Class containing Panadapter Stream data
///   populated by the Panadapter vitaHandler
public struct PanadapterFrame {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  //  public var startingBinNumber = 0     // Index of first bin
  //  public var segmentBinCount = 0       // Number of bins
  //  public var binSize = 0               // Bin size in bytes
  public var frameBinCount = 0         // number of bins in the complete frame
  //  public var frameNumber = 0           // Frame number
  public var bins = [UInt16]()         // Array of bin values
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  /// Initialize a PanadapterFrame
  ///
  /// - Parameter frameSize:    max number of Panadapter samples
  public init(frameSize: Int) {
    // allocate the bins array
    self.bins = [UInt16](repeating: 0, count: frameSize)
  }
}
