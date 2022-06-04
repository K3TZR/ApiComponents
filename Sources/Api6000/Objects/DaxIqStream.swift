//
//  DaxIqStream.swift
//  Components6000/Radio/Objects
//
//  Created by Douglas Adams on 3/9/17.
//  Copyright © 2017 Douglas Adams & Mario Illgen. All rights reserved.
//

import Foundation
import Accelerate

import Shared
import Vita

// DaxIqStream Class implementation
//      creates an DaxIqStream instance to be used by a Client to support the
//      processing of a stream of IQ data from the Radio to the client. DaxIqStream
//      structs are added / removed by the incoming TCP messages. DaxIqStream
//      objects periodically receive IQ data in a UDP stream. They are collected
//      in the Model.daxIqStreams collection.

public struct DaxIqStream: Identifiable {
  // ------------------------------------------------------------------------------
  // MARK: - Public properties
  
  public internal(set) var id: DaxIqStreamId
  public internal(set) var initialized = false
  public internal(set) var isStreaming = false

  public internal(set) var channel = 0
  public internal(set) var clientHandle: Handle = 0
  public internal(set) var ip = ""
  public internal(set) var isActive = false
  public internal(set) var pan: PanadapterId = 0
  public internal(set) var rate = 0
  public var delegate: StreamHandler?
  public private(set) var rxLostPacketCount = 0
  
  public enum DaxIqStreamToken: String {
    case channel        = "daxiq_channel"
    case clientHandle   = "client_handle"
    case ip
    case isActive       = "active"
    case pan
    case rate           = "daxiq_rate"
    case type
  }
  
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
  // MARK: - Private Command methods
  
  //    private func streamSet(_ token: DaxIqTokens, _ value: Any) {
  //        _api.send("stream set \(id.hex) \(token.rawValue)=\(rate)")
  //    }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Parse a Stream status message
  /// - Parameters:
  ///   - keyValues:      a KeyValuesArray
  ///   - radio:          the current Radio class
  ///   - queue:          a parse Queue for the object
  ///   - inUse:          false = "to be deleted"
  static func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id
    if let id =  properties[0].key.streamId {
      // is the object in use?
      if inUse {
        // YES, does it exist?
        if Model.shared.daxIqStreams[id: id] == nil {
          // create a new object & add it to the collection
          Model.shared.daxIqStreams[id: id] = DaxIqStream(id)
          log("DaxIqStream \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values for parsing
        Model.shared.daxIqStreams[id: id]?.parseProperties( Array(properties.dropFirst(1)) )
        
      } else {
        // NO, does it exist?
        if Model.shared.daxIqStreams[id: id] != nil {
          // YES, remove it
          remove(id)
        }
      }
    }
  }

  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         a DaxIqStream Id
  ///   - property:   a DaxIqStream Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, _ id: DaxIqStreamId, property: DaxIqStreamToken, value: Any) {
    // FIXME: add commands
  }

  /// Remove the specified DaxIqStream
  /// - Parameter id:     a DaxIqStreamId
  public static func remove(_ id: DaxIqStreamId) {
    Model.shared.daxIqStreams.remove(id: id)
    log("DaxIqStream removed: id = \(id.hex)", .debug, #function, #file, #line)
  }
  
  /// Remove all DaxIqStreams
  public static func removeAll() {
    for daxIqStream in Model.shared.daxIqStreams {
      Model.shared.daxIqStreams.remove(id: daxIqStream.id)
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Parse IQ Stream key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private mutating func parseProperties(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      
      guard let token = DaxIqStreamToken(rawValue: property.key) else {
        // unknown Key, log it and ignore the Key
        log("DaxIqStream, unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // known keys, in alphabetical order
      switch token {
        
      case .clientHandle:     clientHandle = property.value.handle ?? 0
      case .channel:          channel = property.value.iValue
      case .ip:               ip = property.value
      case .isActive:         isActive = property.value.bValue
      case .pan:              pan = property.value.streamId ?? 0
      case .rate:             rate = property.value.iValue
      case .type:             break  // included to inhibit unknown token warnings
      }
    }
    // is it initialized?
    if initialized == false && clientHandle != 0 {
      // NO, it is now
      initialized = true
      log("DaxIqStream \(id.hex): initialized channel = \(channel)", .debug, #function, #file, #line)
    }
  }
  
  /// Send a command to Set a DaxIqStream property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified DaxIqStream
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: DaxIqStreamId, _ token: DaxIqStreamToken, _ value: Any) {
    // FIXME: add commands
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  /// Process the IqStream Vita struct
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
