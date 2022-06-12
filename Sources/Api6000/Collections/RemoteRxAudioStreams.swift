//
//  RemoteRxAudioStreams.swift
//  
//
//  Created by Douglas Adams on 6/12/22.
//

import Foundation
import IdentifiedCollections

import Vita
import Shared

public actor RemoteRxAudioStreams {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public enum RemoteRxAudioStreamToken : String {
    case clientHandle = "client_handle"
    case compression
    case ip
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _remoteRxAudioStreams = IdentifiedArrayOf<RemoteRxAudioStream>()
  
  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = RemoteRxAudioStreams()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func add(_ remoteRxAudioStream: RemoteRxAudioStream) {
    _remoteRxAudioStreams[id: remoteRxAudioStream.id] = remoteRxAudioStream
    updateModel()
  }
  
  public func exists(id: RemoteRxAudioStreamId) -> Bool {
    _remoteRxAudioStreams[id: id] != nil
  }
  
  /// Parse an RemoteRxAudioStream status message
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
          add( RemoteRxAudioStream(id) )
          log("RemoteRxAudioStream \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values for parsing (dropping the Id)
        parseProperties( id, Array(properties.dropFirst(2)) )
        
      } else {
        remove(id)
      }
    }
  }

  /// Remove a RemoteRxAudioStream
  /// - Parameter id:   a RemoteRxAudioStream Id
  public func remove(_ id: RemoteRxAudioStreamId)  {
    _remoteRxAudioStreams.remove(id: id)
    log("RemoteRxAudioStream \(id.hex): removed", .debug, #function, #file, #line)

    updateModel()
  }
  
  /// Remove all RemoteRxAudioStreams
  public func removeAll()  {
    for remoteRxAudioStream in _remoteRxAudioStreams {
      remove(remoteRxAudioStream.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  ///  Parse RemoteRxAudioStream key/value pairs
  /// - Parameter properties: a KeyValuesArray
  private func parseProperties(_ id: RemoteRxAudioStreamId, _ properties: KeyValuesArray) {
    // process each key/value pair
    for property in properties {
      // check for unknown Keys
      guard let token = RemoteRxAudioStreamToken(rawValue: property.key) else {
        // log it and ignore the Key
        log("RemoteRxAudioStream, unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // known Keys, in alphabetical order
      switch token {
        
      case .clientHandle: _remoteRxAudioStreams[id: id]?.clientHandle = property.value.handle ?? 0
      case .compression:  _remoteRxAudioStreams[id: id]?.compression = property.value.lowercased()
      case .ip:           _remoteRxAudioStreams[id: id]?.ip = property.value
      }
    }
    // is it initialized?
    if _remoteRxAudioStreams[id: id]?.initialized == false && _remoteRxAudioStreams[id: id]?.clientHandle != 0 {
      // NO, it is now
      _remoteRxAudioStreams[id: id]?.initialized = true
      log("RemoteRxAudioStream \(id.hex): initialized handle = \(_remoteRxAudioStreams[id: id]?.clientHandle.hex)", .debug, #function, #file, #line)
    }
    updateModel()
  }

  private func updateModel() {
    Task {
      await Model.shared.setRemoteRxAudioStreams(_remoteRxAudioStreams)
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods


  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         a RemoteRxAudioStream Id
  ///   - token:      a RemoteRxAudioStream Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, _ id: RemoteRxAudioStreamId, token: RemoteRxAudioStreamToken, value: Any) {
    // FIXME: add commands
  }
 
  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Send a command to Set a property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         ta RemoteRxAudioStream Id
  ///   - token:      a RemoteRxAudioStream Token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: RemoteRxAudioStreamId, _ token: RemoteRxAudioStreamToken, _ value: Any) {
    // FIXME: add commands
  }
}

// ----------------------------------------------------------------------------
// MARK: - RemoteRxAudioStream Struct

public struct RemoteRxAudioStream: Identifiable {

  // ------------------------------------------------------------------------------
  // MARK: - Static properties
  
  public static let sampleRate: Double = 24_000
  public static let frameCount = 240
  public static let channelCount = 2
  public static let elementSize = MemoryLayout<Float>.size
  public static let isInterleaved = true
  public static let application = 2049

  // ------------------------------------------------------------------------------
  // MARK: - Public properties
  
  public enum Compression : String {
    case opus
    case none
  }
  
  public let id: RemoteRxAudioStreamId

  public var initialized = false
  public var isStreaming = false
  public var clientHandle: Handle = 0
  public var compression = ""
  public var ip = ""
  
  public var delegate: StreamHandler?
    
  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _vita: Vita?
  private var _rxPacketCount = 0
  private var _rxLostPacketCount = 0
  private var _txSampleCount = 0
  private var _rxSequenceNumber = -1
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: RemoteRxAudioStreamId) { self.id = id }

  // ----------------------------------------------------------------------------
  // MARK: - Public methods

  /// Receive RxRemoteAudioStream audio
  /// - Parameters:
  ///   - vita:               an Opus Vita struct
  public mutating func vitaProcessor(_ vita: Vita) {
    
    // FIXME: This assumes Opus encoded audio
    
    if isStreaming == false {
      isStreaming = true
      // log the start of the stream
      log("RemoteRxAudio Stream started: \(id.hex)", .info, #function, #file, #line)
    }
    if compression == "opus" {
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
        log("RemoteRxAudioStream, delayed frame(s) ignored: expected \(expected), received \(received)", .warning, #function, #file, #line)
        return
        
      case (let expected, let received) where received > expected:
        _rxLostPacketCount += 1
        
        // from a later group, jump forward
        let lossPercent = String(format: "%04.2f", (Float(_rxLostPacketCount)/Float(_rxPacketCount)) * 100.0 )
        log("RemoteRxAudioStream, missing frame(s) skipped: expected \(expected), received \(received), loss = \(lossPercent) %", .warning, #function, #file, #line)
        
        // Pass an error frame (count == 0) to the Opus delegate
        delegate?.streamHandler( RemoteRxAudioFrame(payload: vita.payloadData, sampleCount: 0) )
        
        _rxSequenceNumber = received
        fallthrough
        
      default:
        // received == expected
        // calculate the next Sequence Number
        _rxSequenceNumber = (_rxSequenceNumber + 1) % 16
        
        // Pass the data frame to the Opus delegate
        delegate?.streamHandler( RemoteRxAudioFrame(payload: vita.payloadData, sampleCount: vita.payloadSize) )
      }
      
    } else {
      log("RemoteRxAudioStream, compression != opus: frame ignored", .warning, #function, #file, #line)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - RemoteRxAudioStream (Opus) data Struct

public struct RemoteRxAudioFrame {
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public var samples: [UInt8]                     // array of samples
  public var numberOfSamples: Int                 // number of samples
  //  public var duration: Float                     // frame duration (ms)
  //  public var channels: Int                       // number of channels (1 or 2)
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  /// Initialize a RemoteRxAudioFrame
  /// - Parameters:
  ///   - payload:            pointer to the Vita packet payload
  ///   - numberOfSamples:    number of Samples in the payload
  public init(payload: [UInt8], sampleCount: Int) {
    // allocate the samples array
    samples = [UInt8](repeating: 0, count: sampleCount)
    
    // save the count and copy the data
    numberOfSamples = sampleCount
    memcpy(&samples, payload, sampleCount)
    
    // Flex 6000 series always uses:
    //     duration = 10 ms
    //     channels = 2 (stereo)
    
    //    // determine the frame duration
    //    let durationCode = (samples[0] & 0xF8)
    //    switch durationCode {
    //    case 0xC0:
    //      duration = 2.5
    //    case 0xC8:
    //      duration = 5.0
    //    case 0xD0:
    //      duration = 10.0
    //    case 0xD8:
    //      duration = 20.0
    //    default:
    //      duration = 0
    //    }
    //    // determine the number of channels (mono = 1, stereo = 2)
    //    channels = (samples[0] & 0x04) == 0x04 ? 2 : 1
  }
}


