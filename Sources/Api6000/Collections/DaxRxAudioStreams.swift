//
//  DaxRxAudioStreams.swift
//  
//
//  Created by Douglas Adams on 6/12/22.
//

import Foundation
import IdentifiedCollections

import Vita
import Shared

public actor DaxRxAudioStreams {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public enum DaxRxAudioStreamToken: String {
    case clientHandle   = "client_handle"
    case daxChannel     = "dax_channel"
    case ip
    case slice
    case type
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _daxRxAudioStreams = IdentifiedArrayOf<DaxRxAudioStream>()
  
  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = DaxRxAudioStreams()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func add(_ daxRxAudioStream: DaxRxAudioStream) {
    _daxRxAudioStreams[id: daxRxAudioStream.id] = daxRxAudioStream
    updateModel()
  }
  
  public func exists(id: DaxRxAudioStreamId) -> Bool {
    _daxRxAudioStreams[id: id] != nil
  }
  
  /// Parse an AudioStream status message
  /// - Parameters:
  ///   - properties:     a KeyValuesArray
  ///   - inUse:          false = "to be deleted"
  public static func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id
    if let id =  properties[0].key.streamId {
      // is the object in use?
      if inUse {
        // YES, does it exist?
        if !exists(id: id){
          // NO, create a new object & add it to the collection
          add( DaxRxAudioStream(id) )
          log("DaxRxAudioStream \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values for parsing
        parseProperties( id, Array(properties.dropFirst(1)) )
        
      } else {
        remove(id)
      }
    }
  }

  /// Remove a DaxRxAudioStream
  /// - Parameter id:   a DaxRxAudioStream Id
  public func remove(_ id: DaxRxAudioStreamId)  {
    _daxRxAudioStreams.remove(id: id)
    log("DaxRxAudioStream \(id.hex): removed", .debug, #function, #file, #line)

    updateModel()
  }
  
  /// Remove all DaxRxAudioStreams
  public func removeAll()  {
    for daxRxAudioStream in _daxRxAudioStreams {
      remove(daxRxAudioStream.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Parse Audio Stream key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private func parseProperties(_ id: DaxRxAudioStreamId, _ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown keys
      guard let token = DaxRxAudioStreamToken(rawValue: property.key) else {
        // log it and ignore the Key
        log("DaxRxAudioStream, unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // known keys, in alphabetical order
      switch token {
        
      case .clientHandle: _daxRxAudioStreams[id: id]?.clientHandle = property.value.handle ?? 0
      case .daxChannel:   _daxRxAudioStreams[id: id]?.daxChannel = property.value.iValue
      case .ip:           _daxRxAudioStreams[id: id]?.ip = property.value
      case .type:         break  // included to inhibit unknown token warnings
      case .slice:        break  // FIXME: ?????
//        // do we have a good reference to the GUI Client?
//        if let handle = radio.findHandle(for: radio.boundClientId) {
//          // YES,
//          self.slice = radio.findSlice(letter: property.value, guiClientHandle: handle)
//          let gain = rxGain
//          rxGain = 0
//          rxGain = gain
//        } else {
//          // NO, clear the Slice reference and carry on
//          slice = nil
//          continue
//        }
      }
    }
    // is it initialized?
    if _daxRxAudioStreams[id: id]?.initialized == false && _daxRxAudioStreams[id: id]?.clientHandle != 0 {
      // NO, it is now
      _daxRxAudioStreams[id: id]?.initialized = true
      log("DaxRxAudioStream \(id.hex): initialized handle = \(_daxRxAudioStreams[id: id]?.clientHandle.hex)", .debug, #function, #file, #line)

    }
    updateModel()
  }

  private func updateModel() {
    Task {
      await Model.shared.setDaxRxAudioStreams(_daxRxAudioStreams)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Set a property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         a DaxRxAudioStream Id
  ///   - token:      a DaxRxAudioStream Token
  ///   - value:      the new value
  public static nonisolated func setProperty(radio: Radio, _ id: DaxRxAudioStreamId, token: DaxRxAudioStreamToken, value: Any) {
    // FIXME: add commands
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Send a command to set a property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         a DaxRxAudioStream Id
  ///   - token:      a DaxRxAudioStream Token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: DaxRxAudioStreamId, _ token: DaxRxAudioStreamToken, _ value: Any) {
    // FIXME: add commands
  }
}

// ----------------------------------------------------------------------------
// MARK: - DaxRxAudioStream Struct

public struct DaxRxAudioStream: Identifiable {
  // ------------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: DaxRxAudioStreamId
  
  public var initialized = false
  public var isStreaming = false
  public var clientHandle: Handle = 0
  public var ip = ""
  public var slice: Slice?
  public var daxChannel = 0
  public var rxGain = 0
  public var delegate: StreamHandler?
  public var rxLostPacketCount = 0
  
  // ------------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _rxPacketCount      = 0
  private var _rxLostPacketCount  = 0
  private var _rxSequenceNumber   = -1
  
  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: DaxRxAudioStreamId) { self.id = id }

  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  /// Process the DaxAudioStream Vita struct
  /// - Parameters:
  ///   - vita:       a Vita struct
  ///
  public mutating func vitaProcessor(_ vita: Vita) {
    if isStreaming == false {
      isStreaming = true
      // log the start of the stream
      log("DaxRxAudio Stream started: \(id.hex)", .info, #function, #file, #line)
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
      log("DaxRxAudioStream, delayed frame(s) ignored: expected \(expected), received \(received)", .warning, #function, #file, #line)
      return
      
    case (let expected, let received) where received > expected:
      _rxLostPacketCount += 1
      
      // from a later group, jump forward
      let lossPercent = String(format: "%04.2f", (Float(_rxLostPacketCount)/Float(_rxPacketCount)) * 100.0 )
      log("DaxRxAudioStream, missing frame(s) skipped: expected \(expected), received \(received), loss = \(lossPercent) %", .warning, #function, #file, #line)
      
      _rxSequenceNumber = received
      fallthrough
      
    default:
      // received == expected
      // calculate the next Sequence Number
      _rxSequenceNumber = (_rxSequenceNumber + 1) % 16
      
      if vita.classCode == .daxReducedBw {
        delegate?.streamHandler( DaxRxReducedAudioFrame(payload: vita.payloadData, numberOfSamples: vita.payloadSize / 2, daxChannel: daxChannel) )
        
      } else {
        delegate?.streamHandler( DaxRxAudioFrame(payload: vita.payloadData, numberOfSamples: vita.payloadSize / (4 * 2), daxChannel: daxChannel) )
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - DaxRxAudioStream data Struct

public struct DaxRxAudioFrame {
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public var numberOfSamples  : Int
  public var daxChannel       : Int
  public var leftAudio        = [Float]()
  public var rightAudio       = [Float]()
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  /// Initialize a DaxRxAudioFrame
  /// - Parameters:
  ///   - payload:            pointer to the Vita packet payload
  ///   - numberOfSamples:    number of Samples in the payload
  public init(payload: [UInt8], numberOfSamples: Int, daxChannel: Int = -1) {
    
    self.numberOfSamples = numberOfSamples
    self.daxChannel = daxChannel
    
    // allocate the samples arrays
    self.leftAudio = [Float](repeating: 0, count: numberOfSamples)
    self.rightAudio = [Float](repeating: 0, count: numberOfSamples)
    
    payload.withUnsafeBytes { (payloadPtr) in
      // 32-bit Float stereo samples
      // get a pointer to the data in the payload
      let wordsPtr = payloadPtr.bindMemory(to: UInt32.self)
      
      // allocate temporary data arrays
      var dataLeft = [UInt32](repeating: 0, count: numberOfSamples)
      var dataRight = [UInt32](repeating: 0, count: numberOfSamples)
      
      // Swap the byte ordering of the samples & place it in the dataFrame left and right samples
      for i in 0..<numberOfSamples {
        dataLeft[i] = CFSwapInt32BigToHost(wordsPtr[2*i])
        dataRight[i] = CFSwapInt32BigToHost(wordsPtr[(2*i) + 1])
      }
      // copy the data as is -- it is already floating point
      memcpy(&leftAudio, &dataLeft, numberOfSamples * 4)
      memcpy(&rightAudio, &dataRight, numberOfSamples * 4)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - DaxRxAudioStream data Struct (reduced BW)

public struct DaxRxReducedAudioFrame {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public var numberOfSamples  : Int
  public var daxChannel       : Int
  public var leftAudio        = [Float]()
  public var rightAudio       = [Float]()
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  /// Initialize a DaxRxReducedAudioFrame
  /// - Parameters:
  ///   - payload:            pointer to the Vita packet payload
  ///   - numberOfSamples:    number of Samples in the payload
  public init(payload: [UInt8], numberOfSamples: Int, daxChannel: Int = -1) {
    let oneOverMax: Float = 1.0 / Float(Int16.max)
    
    self.numberOfSamples = numberOfSamples
    self.daxChannel = daxChannel
    
    // allocate the samples arrays
    self.leftAudio = [Float](repeating: 0, count: numberOfSamples)
    self.rightAudio = [Float](repeating: 0, count: numberOfSamples)
    
    payload.withUnsafeBytes { (payloadPtr) in
      // Int16 Mono Samples
      // get a pointer to the data in the payload
      let wordsPtr = payloadPtr.bindMemory(to: Int16.self)
      
      // allocate temporary data arrays
      var dataLeft = [Float](repeating: 0, count: numberOfSamples)
      var dataRight = [Float](repeating: 0, count: numberOfSamples)
      
      // Swap the byte ordering of the samples & place it in the dataFrame left and right samples
      for i in 0..<numberOfSamples {
        let uIntVal = CFSwapInt16BigToHost(UInt16(bitPattern: wordsPtr[i]))
        let intVal = Int16(bitPattern: uIntVal)
        
        let floatVal = Float(intVal) * oneOverMax
        
        dataLeft[i] = floatVal
        dataRight[i] = floatVal
      }
      // copy the data as is -- it is already floating point
      memcpy(&leftAudio, &dataLeft, numberOfSamples * 4)
      memcpy(&rightAudio, &dataRight, numberOfSamples * 4)
    }
  }
}


