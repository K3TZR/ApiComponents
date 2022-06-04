//
//  DaxTxAudioStream.swift
//  Components6000/Radio/Objects
//
//  Created by Mario Illgen on 27.03.17.
//  Copyright © 2017 Douglas Adams & Mario Illgen. All rights reserved.
//

import Foundation

import Shared
import Vita

// DaxTxAudioStream Class implementation
//      creates a DaxTxAudioStream instance to be used by a Client to support the
//      processing of a stream of Audio from the client to the Radio. DaxTxAudioStream
//      structs are added / removed by the incoming TCP messages. DaxTxAudioStream
//      objects periodically send Tx Audio in a UDP stream. They are collected in
//      the Model.daxTxAudioStreams collection.

public struct DaxTxAudioStream: Identifiable {
  // ------------------------------------------------------------------------------
  // MARK: - Published properties
  
  public internal(set) var id: DaxTxAudioStreamId
  public internal(set) var initialized = false
  public internal(set) var isStreaming = false

  public internal(set) var clientHandle: Handle = 0
  public internal(set) var ip = ""
  public internal(set) var isTransmitChannel = false
  public internal(set) var txGain = 0 {
    didSet { if txGain != oldValue {
      if txGain == 0 {
        txGainScalar = 0.0
        return
      }
      let db_min:Float = -10.0
      let db_max:Float = +10.0
      let db:Float = db_min + (Float(txGain) / 100.0) * (db_max - db_min)
      txGainScalar = pow(10.0, db / 20.0)
    }}}
  public internal(set) var txGainScalar: Float = 0
  
 public  enum DaxTxAudioStreamToken: String {
    case clientHandle      = "client_handle"
    case ip
    case isTransmitChannel = "tx"
    case type
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _txSequenceNumber = 0
  private var _vita: Vita?
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: DaxTxAudioStreamId) { self.id = id  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  /// Send Tx Audio to the Radio
  /// - Parameters:
  ///   - left:                   array of left samples
  ///   - right:                  array of right samples
  ///   - samples:                number of samples
  /// - Returns:                  success
  public mutating func sendTXAudio(radio: Radio, left: [Float], right: [Float], samples: Int, sendReducedBW: Bool = false) -> Bool {
    var samplesSent = 0
    var samplesToSend = 0
    
    // skip this if we are not the DAX TX Client
    guard isTransmitChannel else { return false }
    
    // get a TxAudio Vita
    if _vita == nil { _vita = Vita(type: .txAudio, streamId: id, reducedBW: sendReducedBW) }
    
    let kMaxSamplesToSend = 128     // maximum packet samples (per channel)
    let kNumberOfChannels = 2       // 2 channels
    
    if sendReducedBW {
      // REDUCED BANDWIDTH
      // create new array for payload (mono samples)
      var uint16Array = [UInt16](repeating: 0, count: kMaxSamplesToSend)
      
      while samplesSent < samples {
        // how many samples this iteration? (kMaxSamplesToSend or remainder if < kMaxSamplesToSend)
        samplesToSend = min(kMaxSamplesToSend, samples - samplesSent)
        
        // interleave the payload & scale with tx gain
        for i in 0..<samplesToSend {
          var floatSample = left[i + samplesSent] * txGainScalar
          
          if floatSample > 1.0 {
            floatSample = 1.0
          } else if floatSample < -1.0 {
            floatSample = -1.0
          }
          let intSample = Int16(floatSample * 32767.0)
          uint16Array[i] = CFSwapInt16HostToBig(UInt16(bitPattern: intSample))
        }
        _vita!.payloadData = uint16Array.withUnsafeBytes { Array($0) }
        
        // set the length of the packet
        _vita!.payloadSize = samplesToSend * MemoryLayout<Int16>.size            // 16-Bit mono samples
        _vita!.packetSize = _vita!.payloadSize + MemoryLayout<VitaHeader>.size   // payload size + header size
        
        // set the sequence number
        _vita!.sequence = _txSequenceNumber
        
        // encode the Vita class as data and send to radio
        if let data = Vita.encodeAsData(_vita!) { radio.send(data) }
        
        // increment the sequence number (mod 16)
        _txSequenceNumber = (_txSequenceNumber + 1) % 16
        
        // adjust the samples sent
        samplesSent += samplesToSend
      }
      
    } else {
      // NORMAL BANDWIDTH
      // create new array for payload (interleaved L/R stereo samples)
      var floatArray = [Float](repeating: 0, count: kMaxSamplesToSend * kNumberOfChannels)
      
      while samplesSent < samples {
        // how many samples this iteration? (kMaxSamplesToSend or remainder if < kMaxSamplesToSend)
        samplesToSend = min(kMaxSamplesToSend, samples - samplesSent)
        let numFloatsToSend = samplesToSend * kNumberOfChannels
        
        // interleave the payload & scale with tx gain
        for i in 0..<samplesToSend {                                         // TODO: use Accelerate
          floatArray[2 * i] = left[i + samplesSent] * txGainScalar
          floatArray[(2 * i) + 1] = left[i + samplesSent] * txGainScalar
        }
        floatArray.withUnsafeMutableBytes{ bytePtr in
          let uint32Ptr = bytePtr.bindMemory(to: UInt32.self)
          
          // swap endianess of the samples
          for i in 0..<numFloatsToSend {
            uint32Ptr[i] = CFSwapInt32HostToBig(uint32Ptr[i])
          }
        }
        _vita!.payloadData = floatArray.withUnsafeBytes { Array($0) }
        
        // set the length of the packet
        _vita!.payloadSize = numFloatsToSend * MemoryLayout<UInt32>.size            // 32-Bit L/R samples
        _vita!.packetSize = _vita!.payloadSize + MemoryLayout<VitaHeader>.size      // payload size + header size
        
        // set the sequence number
        _vita!.sequence = _txSequenceNumber
        
        // encode the Vita class as data and send to radio
        if let data = Vita.encodeAsData(_vita!) { radio.send(data) }
        
        // increment the sequence number (mod 16)
        _txSequenceNumber = (_txSequenceNumber + 1) % 16
        
        // adjust the samples sent
        samplesSent += samplesToSend
      }
    }
    return true
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods

  /// Parse a TxAudioStream status message
  /// - Parameters:
  ///   - keyValues:      a KeyValuesArray
  ///   - inUse:          false = "to be deleted"
  public static func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id
    if let id =  properties[0].key.streamId {
      // is the object in use?
      if inUse {
        // YES, does it exist?
        if Model.shared.daxTxAudioStreams[id: id] == nil {
          // NO, create a new object & add it to the collection
          Model.shared.daxTxAudioStreams[id: id] = DaxTxAudioStream(id)
          log("DaxTxAudioStream \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values for parsing
        Model.shared.daxTxAudioStreams[id: id]?.parseProperties( Array(properties.dropFirst(1)) )
        
      }  else {
        // NO, does it exist?
        if Model.shared.daxTxAudioStreams[id: id] != nil {
          // YES, remove it
          remove(id)
        }
      }
    }
  }

  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         a DaxTxAudioStream Id
  ///   - property:   an DaxTxAudioStream Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, _ id: DaxTxAudioStreamId, property: DaxTxAudioStreamToken, value: Any) {
    // FIXME: add commands
  }

  /// Remove the specified DaxTxAudioStream
  /// - Parameter id:     a DaxTxAudioStreamId
  public static func remove(_ id: DaxTxAudioStreamId) {
    Model.shared.daxTxAudioStreams.remove(id: id)
    log("DaxTxAudioStream \(id.hex): removed", .debug, #function, #file, #line)
  }
  
  /// Remove all DaxTxAudioStream
   public static func removeAll() {
    for daxTxAudioStream in Model.shared.daxTxAudioStreams {
      remove(daxTxAudioStream.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods

  /// Parse TX Audio Stream key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private mutating func parseProperties(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown keys
      guard let token = DaxTxAudioStreamToken(rawValue: property.key) else {
        // unknown Key, log it and ignore the Key
        log("DaxTxAudioStream, unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // known keys, in alphabetical order
      switch token {
        
      case .clientHandle:       clientHandle = property.value.handle ?? 0
      case .ip:                 ip = property.value
      case .isTransmitChannel:  isTransmitChannel = property.value.bValue
      case .type:               break  // included to inhibit unknown token warnings
      }
    }
    // is it initialized?
    if initialized == false && clientHandle != 0 {
      // NO, it is now
      initialized = true
      log("DaxTxAudioStream \(id.hex): initialized handle = \(clientHandle.hex)", .debug, #function, #file, #line)
    }
  }
  
  /// Send a command to Set a DaxTxAudioStream property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified DaxTxAudioStream
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: DaxTxAudioStreamId, _ token: DaxTxAudioStreamToken, _ value: Any) {
    // FIXME: add commands
  }
}
