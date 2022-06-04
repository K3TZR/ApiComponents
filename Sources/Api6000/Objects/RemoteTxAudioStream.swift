//
//  RemoteTxAudioStream.swift
//  Components6000/Radio/Objects
//
//  Created by Douglas Adams on 2/9/16.
//  Copyright © 2016 Douglas Adams. All rights reserved.
//

import Foundation

import Shared
import Vita

// RemoteTxAudioStream Struct
//      creates a RemoteTxAudioStream instance to be used by a Client to support the
//      processing of a stream of Audio to the Radio. RemoteTxAudioStream objects
//      are added / removed by the incoming TCP messages. RemoteTxAudioStream objects
//      periodically send Audio in a UDP stream. They are collected in the
//      RemoteTxAudioStreams collection on the Radio object.

public struct RemoteTxAudioStream: Identifiable {
  // ------------------------------------------------------------------------------
  // MARK: - Static properties
  
  public static let application = 2049
  public static let channelCount = 2
  public static let elementSize = MemoryLayout<Float>.size
  public static let frameCount = 240
  public static let isInterleaved = true
  public static let sampleRate: Double = 24_000
  
  // ------------------------------------------------------------------------------
  // MARK: - Public properties
  
  public internal(set) var id : RemoteTxAudioStreamId
  public internal(set) var initialized = false
  public internal(set) var isStreaming = false

  public internal(set) var clientHandle: Handle = 0
  public internal(set) var compression = ""
  public internal(set) var ip = ""
  
  public var delegate: StreamHandler?
  
  public enum RemoteTxAudioStreamToken: String {
    case clientHandle = "client_handle"
    case compression
    case ip
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private properties

//  private var _objects = Model.shared
  private var _suppress = false
  private var _txSequenceNumber = 0
  private var _vita: Vita?
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: RemoteTxAudioStreamId) { self.id = id }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  /// Send Tx Audio to the Radio
  /// - Parameters:
  ///   - buffer:             array of encoded audio samples
  /// - Returns:              success / failure
  public mutating func sendTxAudio(radio: Radio, buffer: [UInt8], samples: Int) {
    guard Model.shared.interlock.state == "TRANSMITTING" else { return }
    
    // FIXME: This assumes Opus encoded audio
    if compression == "opus" {
      // get an OpusTx Vita
      if _vita == nil { _vita = Vita(type: .opusTx, streamId: id) }
      
      // create new array for payload (interleaved L/R samples)
      _vita!.payloadData = buffer
      
      // set the length of the packet
      _vita!.payloadSize = samples                                              // 8-Bit encoded samples
      _vita!.packetSize = _vita!.payloadSize + MemoryLayout<VitaHeader>.size    // payload size + header size
      
      // set the sequence number
      _vita!.sequence = _txSequenceNumber
      
      // encode the Vita class as data and send to radio
      if let data = Vita.encodeAsData(_vita!) { radio.send(data) }
      
      // increment the sequence number (mod 16)
      _txSequenceNumber = (_txSequenceNumber + 1) % 16
      
    } else {
      log("RemoteTxAudioStream, compression != opus: frame ignored", .warning, #function, #file, #line)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods

  /// Parse an RemoteTxAudioStream status message
  /// - Parameters:
  ///   - keyValues:          a KeyValuesArray
  ///   - radio:              the current Radio class
  ///   - queue:              a parse Queue for the object
  ///   - inUse:              false = "to be deleted"
  public static func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id
    if let id =  properties[0].key.streamId {
      // is the object in use?
      if inUse {
        // YES, does it exist?
        if Model.shared.remoteTxAudioStreams[id: id] == nil {
          // create a new object & add it to the collection
          Model.shared.remoteTxAudioStreams[id: id] = RemoteTxAudioStream(id)
          log("RemoteTxAudioStream \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values for parsing (dropping the Id)
        Model.shared.remoteTxAudioStreams[id: id]?.parseProperties( Array(properties.dropFirst(2)) )
        
      } else {
        // NO, does it exist?
        if Model.shared.remoteTxAudioStreams[id: id] != nil {
          // YES, remove it
          remove(id)
        }
      }
    }
  }

  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         a RemoteTxAudioStream Id
  ///   - property:   a RemoteTxAudioStream Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, _ id: RemoteTxAudioStreamId, property: RemoteTxAudioStreamToken, value: Any) {
    // FIXME: add commands
  }

  /// Remove the specified RemoteTxAudioStream
  /// - Parameter id:     a RemoteTxAudioStreamId
  public static func remove(_ id: RemoteTxAudioStreamId) {
    Model.shared.remoteTxAudioStreams.remove(id: id)
    log("RemoteTxAudioStream \(id.hex): removed", .debug, #function, #file, #line)
  }
  
  /// Remove all RemoteTxAudioStreams
  public static func removeAll() {
    for remoteTxAudioStream in Model.shared.remoteTxAudioStreams {
      remove(remoteTxAudioStream.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods

  ///  Parse RemoteTxAudioStream key/value pairs
  /// - Parameter properties: a KeyValuesArray
  private mutating func parseProperties(_ properties: KeyValuesArray) {
    // process each key/value pair
    for property in properties {
      // check for unknown Keys
      guard let token = RemoteTxAudioStreamToken(rawValue: property.key) else {
        // log it and ignore the Key
        log("RemoteTxAudioStream, unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // known Keys, in alphabetical order
      switch token {
        
        // Note: only supports "opus", not sure why the compression property exists (future?)
        
      case .clientHandle: clientHandle = property.value.handle ?? 0
      case .compression:  compression = property.value.lowercased()
      case .ip:           ip = property.value
      }
    }
    // is it initialized?
    if initialized == false && clientHandle != 0 {
      // NO, it is now
      initialized = true
      log("RemoteTxAudioStream \(id.hex): initialized handle = \(Model.shared.remoteTxAudioStreams[id: id]!.clientHandle.hex)", .debug, #function, #file, #line)
    }
  }
  
  /// Send a command to Set a RemoteTxAudioStream property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified RemoteTxAudioStream
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: RemoteTxAudioStreamId, _ token: RemoteTxAudioStreamToken, _ value: Any) {
    // FIXME: add commands
  }
}

