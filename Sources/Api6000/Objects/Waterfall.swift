//
//  Waterfall.swift
//  Api6000Components/Api6000/Objects
//
//  Created by Douglas Adams on 5/31/15.
//  Copyright (c) 2015 Douglas Adams, K3TZR
//

import Foundation
import CoreGraphics

import Shared
// import LogProxy
import Vita

// Waterfall struct implementation
//       creates a Waterfall instance to be used by a Client to support the
//       processing of a Waterfall. Waterfall structs are added / removed by the
//       incoming TCP messages. Waterfall objects periodically receive Waterfall
//       data in a UDP stream. They are collected in the WaterfallsCollection.

public struct Waterfall: Identifiable {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public internal(set) var id: WaterfallId
  public internal(set) var isStreaming = false
  public internal(set) var initialized: Bool = false

  public internal(set) var autoBlackEnabled = false
  public internal(set) var autoBlackLevel: UInt32 = 0
  public internal(set) var blackLevel = 0
  public internal(set) var clientHandle: Handle = 0
  public internal(set) var colorGain = 0
  public internal(set) var delegate: StreamHandler?
  public internal(set) var gradientIndex = 0
  public internal(set) var lineDuration = 0
  public internal(set) var panadapterId: PanadapterId?
  
  public enum WaterfallToken : String {
     case clientHandle         = "client_handle"   // New Api only
     
     // on Waterfall
     case autoBlackEnabled     = "auto_black"
     case blackLevel           = "black_level"
     case colorGain            = "color_gain"
     case gradientIndex        = "gradient_index"
     case lineDuration         = "line_duration"
     
     // unused here
     case available
     case band
     case bandZoomEnabled      = "band_zoom"
     case bandwidth
     case capacity
     case center
     case daxIq                = "daxiq"
     case daxIqChannel         = "daxiq_channel"
     case daxIqRate            = "daxiq_rate"
     case loopA                = "loopa"
     case loopB                = "loopb"
     case panadapterId         = "panadapter"
     case rfGain               = "rfgain"
     case rxAnt                = "rxant"
     case segmentZoomEnabled   = "segment_zoom"
     case wide
     case xPixels              = "x_pixels"
     case xvtr
   }

  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  static var q = DispatchQueue(label: "WaterfallSequenceQ", attributes: [.concurrent])
  private var _expectedFrameNumber = -1
  private var _droppedPackets = 0
  private var _accumulatedBins = 0

  private struct PayloadHeader {  // struct to mimic payload layout
    var firstBinFreq: UInt64    // 8 bytes
    var binBandwidth: UInt64    // 8 bytes
    var lineDuration : UInt32   // 4 bytes
    var segmentBinCount: UInt16    // 2 bytes
    var height: UInt16          // 2 bytes
    var frameNumber: UInt32   // 4 bytes
    var autoBlackLevel: UInt32  // 4 bytes
    var frameBinCount: UInt16       // 2 bytes
    var startingBinNumber: UInt16        // 2 bytes
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _frames = [WaterfallFrame]()
  @Atomic(0, q) private var index: Int
    
//  let _log: Log = { msg,level,function,file,line in
//    log(msg, level, function, file, line)
//  }

  private let _numberOfFrames = 10
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: WaterfallId) {
    self.id = id
    
    // allocate two dataframes
    for _ in 0..<_numberOfFrames {
      _frames.append(WaterfallFrame(frameSize: 4096))
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  /// Parse a Waterfall status message
  /// - Parameters:
  ///   - properties:     a KeyValuesArray of Waterfall properties
  ///   - inUse:          false = "to be deleted"
  public static func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id
    if let id = properties[1].key.streamId {
      // is the object in use?
      if inUse {
        // YES, does it exist?
        if Model.shared.waterfalls[id: id] == nil {
          // Create a Waterfall & add it to the Waterfalls collection
          Model.shared.waterfalls[id: id] = Waterfall(id)
          log("Waterfall \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the key values to the Waterfall for parsing (dropping the Type and Id)
        Model.shared.waterfalls[id: id]?.parseProperties( Array(properties.dropFirst(2)))
        
      } else {
        // NO, does it exist?
        if Model.shared.waterfalls[id: id] != nil {
          // YES, remove it
          remove(id)
        }
      }
    }
  }

  public static func setProperty(radio: Radio, _ id: WaterfallId, property: WaterfallToken, value: Any) {
    switch property {
    case .autoBlackEnabled:   sendCommand( radio, id, .autoBlackEnabled, (value as! Bool).as1or0)
    case .blackLevel:         sendCommand( radio, id, .blackLevel, value)
    case .colorGain:          sendCommand( radio, id, .colorGain, value)
    case .gradientIndex:      sendCommand( radio, id, .gradientIndex, value)
    case .lineDuration:       sendCommand( radio, id, .lineDuration, value)
    default:                  break
    }
  }

  public static func getProperty( _ id: WaterfallId, property: WaterfallToken) -> Any? {
    switch property {
    case .autoBlackEnabled:   return Model.shared.waterfalls[id: id]?.autoBlackEnabled as Any
    case .blackLevel:         return Model.shared.waterfalls[id: id]?.blackLevel as Any
    case .clientHandle:       return Model.shared.waterfalls[id: id]?.clientHandle as Any
    case .colorGain:          return Model.shared.waterfalls[id: id]?.colorGain as Any
    case .gradientIndex:      return Model.shared.waterfalls[id: id]?.gradientIndex as Any
    case .lineDuration:       return Model.shared.waterfalls[id: id]?.lineDuration as Any
    case .panadapterId:       return Model.shared.waterfalls[id: id]!.panadapterId as Any
      // the following are ignored here
    case .available, .band, .bandwidth, .bandZoomEnabled, .capacity, .center, .daxIq, .daxIqChannel,
        .daxIqRate, .loopA, .loopB, .rfGain, .rxAnt, .segmentZoomEnabled, .wide, .xPixels, .xvtr:  return nil
    }
  }

  /// Remove the specified Waterfall
  /// - Parameter id:     a WaterfallId
  public static func remove(_ id: WaterfallId) {
    Model.shared.waterfalls.remove(id: id)
    log("Waterfall \(id.hex): removed", .debug, #function, #file, #line)
  }
  
  /// Remove all Waterfalls
  public static func removeAll() {
    for waterfall in Model.shared.waterfalls {
      remove(waterfall.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Parse Waterfall key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private mutating func parseProperties(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = WaterfallToken(rawValue: property.key) else {
        // log it and ignore the Key
        log("Waterfall \(id.hex) unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // Known keys, in alphabetical order
      switch token {
        
      case .autoBlackEnabled:   autoBlackEnabled = property.value.bValue
      case .blackLevel:         blackLevel = property.value.iValue
      case .clientHandle:       clientHandle = property.value.handle ?? 0
      case .colorGain:          colorGain = property.value.iValue
      case .gradientIndex:      gradientIndex = property.value.iValue
      case .lineDuration:       lineDuration = property.value.iValue
      case .panadapterId:       panadapterId = property.value.streamId ?? 0
        // the following are ignored here
      case .available, .band, .bandwidth, .bandZoomEnabled, .capacity, .center, .daxIq, .daxIqChannel,
          .daxIqRate, .loopA, .loopB, .rfGain, .rxAnt, .segmentZoomEnabled, .wide, .xPixels, .xvtr:  break
      }
    }
    // is it initialized?
    if initialized == false && panadapterId != 0 {
      // NO, it is now
      initialized = true
      log("Waterfall \(id.hex): initialized handle = \(clientHandle.hex)", .debug, #function, #file, #line)
    }
  }
    
  /// Send a command to Set a Waterfall property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Waterfall
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: WaterfallId, _ token: WaterfallToken, _ value: Any) {
      radio.send("display panafall set " + "\(id.hex) " + token.rawValue + "=\(value)")
  }
  
  /// Process the Waterfall Vita struct
  ///
  ///   VitaProcessor protocol method, executes on the streamQ
  ///      The payload of the incoming Vita struct is converted to a WaterfallFrame and
  ///      passed to the Waterfall Stream Handler, called by Radio
  ///
  /// - Parameters:
  ///   - vita:       a Vita struct
  mutating func vitaProcessor(_ vita: Vita, _ testMode: Bool = false) {
    if Model.shared.waterfalls[id: vita.streamId]!.isStreaming == false {
      Model.shared.waterfalls[id: vita.streamId]!.isStreaming = true
      // log the start of the stream
      log("Waterfall stream \(vita.streamId.hex): started", .info, #function, #file, #line)
    }
    
    // Bins are just beyond the payload
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
        // NORMAL MODE
        // populate frame values
        _frames[index].firstBinFreq = CGFloat(CFSwapInt64BigToHost(hdr[0].firstBinFreq)) / 1.048576E6
        _frames[index].binBandwidth = CGFloat(CFSwapInt64BigToHost(hdr[0].binBandwidth)) / 1.048576E6
        _frames[index].lineDuration = Int( CFSwapInt32BigToHost(hdr[0].lineDuration) )
        _frames[index].height = Int( CFSwapInt16BigToHost(hdr[0].height) )
        _frames[index].autoBlackLevel = CFSwapInt32BigToHost(hdr[0].autoBlackLevel)
             
        if _expectedFrameNumber != frameNumber {
          _droppedPackets += (frameNumber - _expectedFrameNumber)
          log("Waterfall: missing frame(s), expected = \(_expectedFrameNumber), received = \(frameNumber), drop count = \(_droppedPackets)", .warning, #function, #file, #line)
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

/// Class containing Waterfall Stream data
///
///   populated by the Waterfall vitaHandler
public struct WaterfallFrame {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public var firstBinFreq: CGFloat = 0.0  // Frequency of first Bin (Hz)
  public var binBandwidth: CGFloat = 0.0  // Bandwidth of a single bin (Hz)
  public var lineDuration  = 0            // Duration of this line (ms)
  //  public var segmentBinCount = 0          // Number of bins
  public var height = 0                   // Height of frame (pixels)
  //  public var frameNumber = 0              // Time code
  public var autoBlackLevel: UInt32 = 0   // Auto black level
  public var frameBinCount = 0            //
  //  public var startingBinNumber = 0        //
  public var bins = [UInt16]()            // Array of bin values
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  /// Initialize a WaterfallFrame
  ///
  /// - Parameter frameSize:    max number of Waterfall samples
  ///
  public init(frameSize: Int) {
    // allocate the bins array
    self.bins = [UInt16](repeating: 0, count: frameSize)
  }
}
