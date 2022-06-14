//
//  DaxMicAudioStreams.swift
//  
//
//  Created by Douglas Adams on 6/12/22.
//

import Foundation
import IdentifiedCollections

import ApiVita
import ApiShared

public actor DaxMicAudioStreams {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public enum DaxMicAudioStreamToken: String {
    case clientHandle = "client_handle"
    case ip
    case type
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _daxMicAudioStreams = IdentifiedArrayOf<DaxMicAudioStream>()
  
  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = DaxMicAudioStreams()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func add(_ daxMicAudioStream: DaxMicAudioStream) {
    _daxMicAudioStreams[id: daxMicAudioStream.id] = daxMicAudioStream
    updateModel()
  }
  
  public func exists(id: DaxMicAudioStreamId) -> Bool {
    _daxMicAudioStreams[id: id] != nil
  }
  
  /// Parse a DAX Mic AudioStream status message
  /// - Parameters:
  ///   - properties:     a KeyValuesArray
  ///   - inUse:          false = "to be deleted"
  public func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id
    if let id =  properties[0].key.streamId {
      // is the object in use?
      if inUse {
        // YES, does it exist?
        if !exists(id: id) {
          // NO, create a new object & add it to the collection
          add( DaxMicAudioStream(id) )
          log("DaxMicAudioStream \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values for parsing
       parseProperties( id, Array(properties.dropFirst(1)) )
        
      } else {
        remove(id)
      }
    }
  }

  /// Remove a DaxMicAudioStream
  /// - Parameter id:   a DaxMicAudioStream Id
  public func remove(_ id: DaxMicAudioStreamId)  {
    _daxMicAudioStreams.remove(id: id)
    log("Tnf \(id.hex): removed", .debug, #function, #file, #line)

    updateModel()
  }
  
  /// Remove all DaxMicAudioStreams
  public func removeAll()  {
    for daxMicAudioStream in _daxMicAudioStreams {
      remove(daxMicAudioStream.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Parse Dax Mic Audio Stream key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private func parseProperties(_ id: DaxMicAudioStreamId, _ properties: KeyValuesArray) {
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
        
      case .clientHandle: _daxMicAudioStreams[id: id]?.clientHandle = property.value.handle ?? 0
      case .ip:           _daxMicAudioStreams[id: id]?.ip = property.value
      case .type:         break  // included to inhibit unknown token warnings
      }
    }
    // is it initialized?
    if _daxMicAudioStreams[id: id]?.initialized == false && _daxMicAudioStreams[id: id]?.clientHandle != 0 {
      // NO, it is now
      _daxMicAudioStreams[id: id]?.initialized = true
      log("DaxMicAudioStream \(id.hex): initialized handle = \(_daxMicAudioStreams[id: id]?.clientHandle.hex ?? "")", .debug, #function, #file, #line)
    }
    updateModel()
  }

  private func updateModel() {
    Task {
      await Model.shared.setDaxMicAudioStreams(_daxMicAudioStreams)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         an DaxMicAudioStream Id
  ///   - property:   an DaxMicAudioStream Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, _ id: DaxMicAudioStreamId, property: DaxMicAudioStreamToken, value: Any) {
    // FIXME: add commands
  }

  public static func remove(_ radio: Radio, id: DaxMicAudioStreamId, callback: ReplyHandler? = nil) {
    radio.send("stream remove \(id.hex)", replyTo: callback)
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods

  
  /// Send a command to Set a DaxMicAudioStream property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified DaxMicAudioStream
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: DaxMicAudioStreamId, _ token: DaxMicAudioStreamToken, _ value: Any) {
    // FIXME: add commands
  }
}


// ----------------------------------------------------------------------------
// MARK: - DaxMicAudioStream Struct

public struct DaxMicAudioStream: Identifiable {
  // ------------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: DaxMicAudioStreamId
 
  public var initialized = false
  public var isStreaming = false
  public var clientHandle: Handle = 0
  public var ip = ""
  public var micGain = 0 {
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
  public var micGainScalar: Float = 0
  
  public var delegate: StreamHandler?
  public var rxLostPacketCount = 0
  
  
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
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods



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
