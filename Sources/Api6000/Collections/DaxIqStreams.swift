//
//  DaxIqStreams.swift
//  
//
//  Created by Douglas Adams on 6/11/22.
//

import Foundation
import Accelerate
import IdentifiedCollections

import Shared
import Vita

public actor DaxIqStreams {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public enum DaxIqStreamToken: String {
    case channel        = "daxiq_channel"
    case clientHandle   = "client_handle"
    case ip
    case isActive       = "active"
    case pan
    case rate           = "daxiq_rate"
    case type
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _daxIqStreams = IdentifiedArrayOf<DaxIqStream>()
  
  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = DaxIqStreams()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func add(_ daxIqStream: DaxIqStream) {
    _daxIqStreams[id: daxIqStream.id] = daxIqStream
    updateModel()
  }
  
  public func exists(id: DaxIqStreamId) -> Bool {
    _daxIqStreams[id: id] != nil
  }
  
  /// Parse a Stream status message
  /// - Parameters:
  ///   - keyValues:      a KeyValuesArray
  ///   - radio:          the current Radio class
  ///   - queue:          a parse Queue for the object
  ///   - inUse:          false = "to be deleted"
  public func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id
    if let id =  properties[0].key.streamId {
      // is the object in use?
      if inUse {
        // YES, does it exist?
        if !exists(id: id) {
          // create a new object & add it to the collection
          add( DaxIqStream(id) )
          log("DaxIqStream \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values for parsing
        parseProperties( id, Array(properties.dropFirst(1)) )
        
      } else {
          remove(id)
      }
    }
  }

  /// Remove a DaxIqStream
  /// - Parameter id:   a DaxIqStream Id
  public func remove(_ id: DaxIqStreamId)  {
    _daxIqStreams.remove(id: id)
    log("DaxIqStream \(id.hex): removed", .debug, #function, #file, #line)

    updateModel()
  }
  
  /// Remove all DaxIqStreams
  public func removeAll()  {
    for daxIqStream in _daxIqStreams {
      remove(daxIqStream.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Parse IQ Stream key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private func parseProperties(_ id: DaxIqStreamId, _ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      
      guard let token = DaxIqStreamToken(rawValue: property.key) else {
        // unknown Key, log it and ignore the Key
        log("DaxIqStream, unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // known keys, in alphabetical order
      switch token {
        
      case .clientHandle:     _daxIqStreams[id: id]?.clientHandle = property.value.handle ?? 0
      case .channel:          _daxIqStreams[id: id]?.channel = property.value.iValue
      case .ip:               _daxIqStreams[id: id]?.ip = property.value
      case .isActive:         _daxIqStreams[id: id]?.isActive = property.value.bValue
      case .pan:              _daxIqStreams[id: id]?.pan = property.value.streamId ?? 0
      case .rate:             _daxIqStreams[id: id]?.rate = property.value.iValue
      case .type:             break  // included to inhibit unknown token warnings
      }
    }
    // is it initialized?
    if _daxIqStreams[id: id]?.initialized == false && _daxIqStreams[id: id]?.clientHandle != 0 {
      // NO, it is now
      _daxIqStreams[id: id]?.initialized = true
      log("DaxIqStream \(id.hex): initialized channel = \(_daxIqStreams[id: id]?.channel ?? 999)", .debug, #function, #file, #line)
    }
    updateModel()
  }
  
  private func updateModel() {
    Task {
      await Model.shared.setDaxIqStreams(_daxIqStreams)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         a DaxIqStream Id
  ///   - property:   a DaxIqStream Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, _ id: DaxIqStreamId, property: DaxIqStreamToken, value: Any) {
    // FIXME: add commands
  }

  
  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Send a command to Set a DaxIqStream property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified DaxIqStream
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: DaxIqStreamId, _ token: DaxIqStreamToken, _ value: Any) {
    // FIXME: add commands
  }
}


// ----------------------------------------------------------------------------
// MARK: - DaxIqStream Struct

public struct DaxIqStream: Identifiable {
  // ------------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: DaxIqStreamId
  
  public var initialized = false
  public var isStreaming = false
  public var channel = 0
  public var clientHandle: Handle = 0
  public var ip = ""
  public var isActive = false
  public var pan: PanadapterId = 0
  public var rate = 0
  public var delegate: StreamHandler?
  public var rxLostPacketCount = 0
  
  // ------------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _initialized = false

  private var _rxPacketCount      = 0
  private var _rxLostPacketCount  = 0
  private var _txSampleCount      = 0
  private var _rxSequenceNumber   = -1
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: DaxIqStreamId) { self.id = id }

  // ----------------------------------------------------------------------------
  // MARK: - Public methods

  /// Process the DaxIqStream Vita struct
  /// - Parameters:
  ///   - vita:       a Vita struct
  public mutating func vitaProcessor(_ vita: Vita) {
    if isStreaming == false {
      isStreaming = true
      // log the start of the stream
      log("DaxIq Stream started: \(id.hex)", .info, #function, #file, #line)
    }
    // is this the first packet?
    if _rxSequenceNumber == -1 {
      _rxSequenceNumber = vita.sequence
      _rxPacketCount = 1
      _rxLostPacketCount = 0
    } else {
      _rxPacketCount += 1
    }
    
    switch (_rxSequenceNumber, vita.sequence) {
      
    case (let expected, let received) where received < expected:
      // from a previous group, ignore it
      log("DaxIqStream, delayed frame(s) ignored: expected \(expected), received \(received)", .warning, #function, #file, #line)
      return
      
    case (let expected, let received) where received > expected:
      _rxLostPacketCount += 1
      
      // from a later group, jump forward
      let lossPercent = String(format: "%04.2f", (Float(_rxLostPacketCount)/Float(_rxPacketCount)) * 100.0 )
      log("DaxIqStream, missing frame(s) skipped: expected \(expected), received \(received), loss = \(lossPercent) %", .warning, #function, #file, #line)
      
      _rxSequenceNumber = received
      fallthrough
      
    default:
      // received == expected
      // calculate the next Sequence Number
      _rxSequenceNumber = (_rxSequenceNumber + 1) % 16
      
      // Pass the data frame to the Opus delegate
      delegate?.streamHandler( DaxIqStreamFrame(payload: vita.payloadData, numberOfBytes: vita.payloadSize, daxIqChannel: channel ))
    }
  }
}

/// Struct containing Dax IQ Stream data
public struct DaxIqStreamFrame {
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public var daxIqChannel                   = -1
  public private(set) var numberOfSamples   = 0
  public var realSamples                    = [Float]()
  public var imagSamples                    = [Float]()
  
  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _kOneOverZeroDBfs  : Float = 1.0 / pow(2.0, 15.0)
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  /// Initialize an IqStreamFrame
  /// - Parameters:
  ///   - payload:        pointer to a Vita packet payload
  ///   - numberOfBytes:  number of bytes in the payload
  public init(payload: [UInt8], numberOfBytes: Int, daxIqChannel: Int) {
    // 4 byte each for left and right sample (4 * 2)
    numberOfSamples = numberOfBytes / (4 * 2)
    self.daxIqChannel = daxIqChannel
    
    // allocate the samples arrays
    realSamples = [Float](repeating: 0, count: numberOfSamples)
    imagSamples = [Float](repeating: 0, count: numberOfSamples)
    
    payload.withUnsafeBytes { (payloadPtr) in
      // get a pointer to the data in the payload
      let wordsPtr = payloadPtr.bindMemory(to: Float32.self)
      
      // allocate temporary data arrays
      var dataLeft = [Float32](repeating: 0, count: numberOfSamples)
      var dataRight = [Float32](repeating: 0, count: numberOfSamples)
      
      // FIXME: is there a better way
      // de-interleave the data
      for i in 0..<numberOfSamples {
        dataLeft[i] = wordsPtr[2*i]
        dataRight[i] = wordsPtr[(2*i) + 1]
      }
      // copy & normalize the data
      vDSP_vsmul(&dataLeft, 1, &_kOneOverZeroDBfs, &realSamples, 1, vDSP_Length(numberOfSamples))
      vDSP_vsmul(&dataRight, 1, &_kOneOverZeroDBfs, &imagSamples, 1, vDSP_Length(numberOfSamples))
    }
  }
}
