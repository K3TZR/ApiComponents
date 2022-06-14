//
//  RemoteTxAudioStreams.swift
//  
//
//  Created by Douglas Adams on 6/12/22.
//

import Foundation
import IdentifiedCollections

import ApiVita
import ApiShared

public actor RemoteTxAudioStreams {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public enum RemoteTxAudioStreamToken: String {
    case clientHandle = "client_handle"
    case compression
    case ip
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _remoteTxAudioStreams = IdentifiedArrayOf<RemoteTxAudioStream>()
  
  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = RemoteTxAudioStreams()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func add(_ remoteTxAudioStream: RemoteTxAudioStream) {
    _remoteTxAudioStreams[id: remoteTxAudioStream.id] = remoteTxAudioStream
    updateModel()
  }
  
  public func exists(id: RemoteTxAudioStreamId) -> Bool {
    _remoteTxAudioStreams[id: id] != nil
  }
  
  /// Parse an RemoteTxAudioStream status message
  /// - Parameters:
  ///   - properties:         a KeyValuesArray
  ///   - inUse:              false = "to be deleted"
  public func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id
    if let id =  properties[0].key.streamId {
      // is the object in use?
      if inUse {
        // YES, does it exist?
        if !exists(id: id) {
          // create a new object & add it to the collection
          add( RemoteTxAudioStream(id) )
          log("RemoteTxAudioStream \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values for parsing (dropping the Id)
        parseProperties( id, Array(properties.dropFirst(2)) )
        
      } else {
        remove(id)
      }
    }
  }

  /// Remove a RemoteTxAudioStream
  /// - Parameter id:   a RemoteTxAudioStream Id
  public func remove(_ id: RemoteTxAudioStreamId)  {
    _remoteTxAudioStreams.remove(id: id)
    log("RemoteTxAudioStream \(id.hex): removed", .debug, #function, #file, #line)

    updateModel()
  }
  
  /// Remove all RemoteTxAudioStreams
  public func removeAll()  {
    for remoteTxAudioStream in _remoteTxAudioStreams {
      remove(remoteTxAudioStream.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  ///  Parse RemoteTxAudioStream key/value pairs
  /// - Parameter properties: a KeyValuesArray
  private func parseProperties(_ id: RemoteTxAudioStreamId, _ properties: KeyValuesArray) {
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
        
      case .clientHandle: _remoteTxAudioStreams[id: id]?.clientHandle = property.value.handle ?? 0
      case .compression:  _remoteTxAudioStreams[id: id]?.compression = property.value.lowercased()
      case .ip:           _remoteTxAudioStreams[id: id]?.ip = property.value
      }
    }
    // is it initialized?
    if _remoteTxAudioStreams[id: id]?.initialized == false && _remoteTxAudioStreams[id: id]?.clientHandle != 0 {
      // NO, it is now
      _remoteTxAudioStreams[id: id]?.initialized = true
      log("RemoteTxAudioStream \(id.hex): initialized handle = \(_remoteTxAudioStreams[id: id]?.clientHandle.hex ?? "")", .debug, #function, #file, #line)
    }
    updateModel()
  }

  private func updateModel() {
    Task {
      await Model.shared.setRemoteTxAudioStreams(_remoteTxAudioStreams)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods

  /// Set a property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         a RemoteTxAudioStream Id
  ///   - token:      a RemoteTxAudioStream Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, _ id: RemoteTxAudioStreamId, token: RemoteTxAudioStreamToken, value: Any) {
    // FIXME: add commands
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods

  /// Send a command to Set a RemoteTxAudioStream property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         a RemoteTxAudioStream Id
  ///   - token:      a RemoteTxAudioStream Token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: RemoteTxAudioStreamId, _ token: RemoteTxAudioStreamToken, _ value: Any) {
    // FIXME: add commands
  }
}

// ----------------------------------------------------------------------------
// MARK: - RemoteTxAudioStream Struct

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
  
  public let id : RemoteTxAudioStreamId
  
  public var initialized = false
  public var isStreaming = false
  public var clientHandle: Handle = 0
  public var compression = ""
  public var ip = ""
  public var delegate: StreamHandler?
    
  // ----------------------------------------------------------------------------
  // MARK: - Private properties

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
//    guard Model.shared.interlock.state == "TRANSMITTING" else { return }
    
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
}

