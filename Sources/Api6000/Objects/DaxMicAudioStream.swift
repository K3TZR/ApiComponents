//
//  DaxMicAudioStream.swift
//  Components6000/Radio/Objects
//
//  Created by Mario Illgen on 27.03.17.
//  Copyright © 2017 Douglas Adams & Mario Illgen. All rights reserved.
//

import Foundation

import Shared
import Vita

// DaxMicAudioStream Class implementation
//      creates a DaxMicAudioStream instance to be used by a Client to support the
//      processing of a stream of Mic Audio from the Radio to the client. DaxMicAudioStream
//      structs are added / removed by the incoming TCP messages. DaxMicAudioStream
//      objects periodically receive Mic Audio in a UDP stream. They are collected
//      in the Model.daxMicAudioStreams collection.

public struct DaxMicAudioStream: Identifiable {
  // ------------------------------------------------------------------------------
  // MARK: - Public properties
  
  public internal(set) var id: DaxMicAudioStreamId
  public internal(set) var initialized = false
  public internal(set) var isStreaming = false

  public internal(set) var clientHandle: Handle = 0
  public internal(set) var ip = ""
  public internal(set) var micGain = 0 {
    didSet { if micGain != oldValue {
      var newGain = micGain
      // check limits
      if newGain > 100 { newGain = 100 }
      if newGain < 0 { newGain = 0 }
      if micGain != newGain {
        micGain = newGain
        if micGain == 0 {
          micGainScalar = 0.0
          return
        }
        let db_min:Float = -10.0;
        let db_max:Float = +10.0;
        let db:Float = db_min + (Float(micGain) / 100.0) * (db_max - db_min);
        micGainScalar = pow(10.0, db / 20.0);
      }
    }}}
  public internal(set) var micGainScalar: Float = 0
  
  public var delegate: StreamHandler?
  public var rxLostPacketCount = 0
  
  public enum DaxMicAudioStreamToken: String {
    case clientHandle = "client_handle"
    case ip
    case type
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - Private properties

  private var _rxPacketCount = 0
  private var _rxLostPacketCount = 0
  private var _rxSequenceNumber = -1
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: DaxMicAudioStreamId) { self.id = id }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Command methods
  
  public func remove(_ radio: Radio, callback: ReplyHandler? = nil) {
    radio.send("stream remove \(id.hex)", replyTo: callback)
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods

  /// Parse a DAX Mic AudioStream status message
  /// - Parameters:
  ///   - keyValues:      a KeyValuesArray
  ///   - radio:          the current Radio class
  ///   - queue:          a parse Queue for the object
  ///   - inUse:          false = "to be deleted"
  public static func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id
    if let id =  properties[0].key.streamId {
      // is the object in use?
      if inUse {
        // YES, does it exist?
        if Model.shared.daxMicAudioStreams[id: id] == nil {
          // NO, create a new object & add it to the collection
          Model.shared.daxMicAudioStreams[id: id] = DaxMicAudioStream(id)
          log("DaxMicAudioStream \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values for parsing
        Model.shared.daxMicAudioStreams[id: id]?.parseProperties( Array(properties.dropFirst(1)) )
        
      } else {
        // NO, does it exist?
        if Model.shared.daxMicAudioStreams[id: id] != nil {
          // YES, remove it
          remove(id)
        }
      }
    }
  }

  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         an Amplifier Id
  ///   - property:   an Amplifier Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, _ id: DaxMicAudioStreamId, property: DaxMicAudioStreamToken, value: Any) {
    // FIXME: add commands
  }

  /// Remove the specified DaxMicAudioStream
  /// - Parameter id:     a DaxMicAudioStreamId
  public static func remove(_ id: DaxMicAudioStreamId) {
    Model.shared.daxMicAudioStreams.remove(id: id)
    log("DaxMicAudioStream \(id.hex): removed", .debug, #function, #file, #line)
  }
  
  /// Remove all DaxMicStreams
  public static func removeAll() {
    for daxMicAudioStream in Model.shared.daxMicAudioStreams {
      remove(daxMicAudioStream.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods

  /// Parse Dax Mic Audio Stream key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private mutating func parseProperties(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown keys
      guard let token = DaxMicAudioStreamToken(rawValue: property.key) else {
        // unknown Key, log it and ignore the Key
        log("DaxMicAudioStream, unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // known keys, in alphabetical order
      switch token {
        
      case .clientHandle: clientHandle = property.value.handle ?? 0
      case .ip:           ip = property.value
      case .type:         break  // included to inhibit unknown token warnings
      }
    }
    // is it initialized?
    if initialized == false && clientHandle != 0 {
      // NO, it is now
      initialized = true
      log("DaxMicAudioStream \(id.hex): initialized handle = \(clientHandle.hex)", .debug, #function, #file, #line)
    }
  }
  
  /// Send a command to Set a DaxMicAudioStream property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified DaxMicAudioStream
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: DaxMicAudioStreamId, _ token: DaxMicAudioStreamToken, _ value: Any) {
    // FIXME: add commands
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public methods

  /// Process the Mic Audio Stream Vita struct
  /// - Parameters:
  ///   - vitaPacket:         a Vita struct
  public mutating func vitaProcessor(_ vita: Vita) {
    if isStreaming == false {
      isStreaming = true
      // log the start of the stream
      log("DaxMicAudioStream started: \(id.hex)", .info, #function, #file, #line)
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
      log("DaxMicAudioStream delayed frame(s) ignored: expected \(expected), received \(received)", .warning, #function, #file, #line)
      return
      
    case (let expected, let received) where received > expected:
      _rxLostPacketCount += 1
      
      // from a later group, jump forward
      let lossPercent = String(format: "%04.2f", (Float(_rxLostPacketCount)/Float(_rxPacketCount)) * 100.0 )
      log("DaxMicAudioStream missing frame(s) skipped: expected \(expected), received \(received), loss = \(lossPercent) %", .warning, #function, #file, #line)
      
      _rxSequenceNumber = received
      fallthrough
      
    default:
      // received == expected
      // calculate the next Sequence Number
      _rxSequenceNumber = (_rxSequenceNumber + 1) % 16
      
      if vita.classCode == .daxReducedBw {
        delegate?.streamHandler( DaxRxReducedAudioFrame(payload: vita.payloadData, numberOfSamples: vita.payloadSize / 2 ))
        
      } else {
        delegate?.streamHandler( DaxRxAudioFrame(payload: vita.payloadData, numberOfSamples: vita.payloadSize / (4 * 2) ))
      }
    }
  }
}
