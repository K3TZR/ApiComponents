//
//  RemoteRxAudioStream.swift
//  Api6000Components/Api6000/Objects
//
//  Created by Douglas Adams on 2/9/16.
//  Copyright © 2016 Douglas Adams. All rights reserved.
//

import Foundation

import Shared
import Vita

// RemoteRxAudioStream
//      creates a RemoteRxAudioStream instance to be used by a Client to support the
//      processing of a stream of Audio from the Radio. RemoteRxAudioStream instances
//      are added / removed by the incoming TCP messages. RemoteRxAudioStream instances
//      periodically receive Audio in a UDP stream. They are collected in the
//      Model.remoteRxAudioStreams collection.
@MainActor
public class RemoteRxAudioStream: Identifiable, Equatable, ObservableObject {
  // Equality
  public nonisolated static func == (lhs: RemoteRxAudioStream, rhs: RemoteRxAudioStream) -> Bool {
    lhs.id == rhs.id
  }

  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: RemoteRxAudioStreamId) { self.id = id }
  
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

  @Published public var clientHandle: Handle = 0
  @Published public var compression = ""
  @Published public var ip = ""
  
  public var delegate: StreamHandler?
  
  public enum Property: String {
    case clientHandle = "client_handle"
    case compression
    case ip
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _vita: Vita?
  private var _rxPacketCount = 0
  private var _rxLostPacketCount = 0
  private var _txSampleCount = 0
  private var _rxSequenceNumber = -1
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Instance methods

  ///  Parse RemoteRxAudioStream key/value pairs
  /// - Parameter properties: a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) async {
    // process each key/value pair
    for property in properties {
      // check for unknown Keys
      guard let token = Property(rawValue: property.key) else {
        // log it and ignore the Key
        log("RemoteRxAudioStream, unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // known Keys, in alphabetical order
      switch token {
        
      case .clientHandle: clientHandle = property.value.handle ?? 0
      case .compression:  compression = property.value.lowercased()
      case .ip:           ip = property.value
      }
    }
    // is it initialized?
    if initialized == false && clientHandle != 0 {
      // NO, it is now
      initialized = true
      log("RemoteRxAudioStream \(id.hex): initialized handle = \(clientHandle.hex)", .debug, #function, #file, #line)
    }
  }

  
  
  
  
  
  
  
  
  
  
  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         a RemoteRxAudioStream Id
  ///   - property:   a RemoteRxAudioStream Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, _ id: RemoteRxAudioStreamId, property: Property, value: Any) {
    // FIXME: add commands
  }

  /// Send a command to Set a RemoteRxAudioStream property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified RemoteRxAudioStream
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: RemoteRxAudioStreamId, _ token: Property, _ value: Any) {
    // FIXME: add commands
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public methods

  /// Receive RxRemoteAudioStream audio
  /// - Parameters:
  ///   - vita:               an Opus Vita struct
  public func vitaProcessor(_ vita: Vita) {
    
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

/// Struct containing RemoteRxAudio (Opus) Stream data
///
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


