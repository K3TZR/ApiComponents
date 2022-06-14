//
//  Meters.swift
//  
//
//  Created by Douglas Adams on 6/11/22.
//

import Foundation
import IdentifiedCollections
import Combine

import ApiShared
import ApiVita

public actor Meters {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public static var meterPublisher = PassthroughSubject<Meter, Never>()
  public static var metersAreStreaming = false
  
  public enum MeterToken: String {
    case desc
    case fps
    case high       = "hi"
    case low
    case name       = "nam"
    case group      = "num"
    case source     = "src"
    case units      = "unit"
  }
  
  public enum Units : String {
    case none
    case amps
    case db
    case dbfs
    case dbm
    case degc
    case degf
    case percent
    case rpm
    case swr
    case volts
    case watts
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _meters = IdentifiedArrayOf<Meter>()
  private var _metersAreStreaming = false
  
  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = Meters()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func add(_ meter: Meter) {
    _meters[id: meter.id] = meter
    updateModel()
  }
  
  public func exists(id: MeterId) -> Bool {
    _meters[id: id] != nil
  }
  
  /// Parse a Meter status message
  /// - Parameters:
  ///   - properties:     a KeyValuesArray of Meter properties
  ///   - inUse:          false = "to be deleted"
  public func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // is the object in use?
    if inUse {
      // YES, extract the Meter Number from the first KeyValues entry
      let components = properties[0].key.components(separatedBy: ".")
      if components.count != 2 {return }
      
      // get the id
      if let id = components[0].objectId {
        // does the meter exist?
        
        if !exists(id: id) {
          // NO, create a new Meter & add it to the Meters collection
          add( Meter(id) )
          log("Meter \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the key values to the Meter for parsing
       parseProperties( id, properties )
      }
      
    } else {
      // NO, get the Id
      if let id = properties[0].key.components(separatedBy: " ")[0].objectId {
        remove(id)
      }
    }
  }

  /// Remove a Meter
  /// - Parameter id:   a Meter Id
  public func remove(_ id: MeterId)  {
    _meters.remove(id: id)
    log("Meter \(id.hex): removed", .debug, #function, #file, #line)

    updateModel()
  }
  
  /// Remove all Meters
  public func removeAll()  {
    for meter in _meters {
      remove(meter.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Parse Meter key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private func parseProperties(_ id: MeterId, _ properties: KeyValuesArray) {
    // process each key/value pair, <n.key=value>
    for property in properties {
      // separate the Meter Number from the Key
      let numberAndKey = property.key.components(separatedBy: ".")
      
      // get the Key
      let key = numberAndKey[1]
      
      // check for unknown Keys
      guard let token = MeterToken(rawValue: key) else {
        // log it and ignore the Key
        log("Meter, unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // known Keys, in alphabetical order
      switch token {
        
      case .desc:     _meters[id: id]?.desc = property.value
      case .fps:      _meters[id: id]?.fps = property.value.iValue
      case .high:     _meters[id: id]?.high = property.value.fValue
      case .low:      _meters[id: id]?.low = property.value.fValue
      case .name:     _meters[id: id]?.name = property.value.lowercased()
      case .group:    _meters[id: id]?.group = property.value
      case .source:   _meters[id: id]?.source = property.value.lowercased()
      case .units:    _meters[id: id]?.units = property.value.lowercased()
      }
    }
    // is it initialized?
    if _meters[id: id]?.initialized == false && _meters[id: id]?.group != "" && _meters[id: id]?.units != "" {
      //NO, it is now
      _meters[id: id]?.initialized = true
      log("Meter \(id): initialized \(_meters[id: id]?.name ?? ""), source = \(_meters[id: id]?.source ?? ""), group = \(_meters[id: id]?.group ?? "")", .debug, #function, #file, #line)
    }
    updateModel()
  }

  private func updateModel() {
    Task {
      await Model.shared.setMeters(_meters)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  /// Process the Vita struct containing Meter data
  /// - Parameters:
  ///   - vita:        a Vita struct
  public func vitaProcessor(_ vita: Vita) {
    let kDbDbmDbfsSwrDenom: Float = 128.0   // denominator for Db, Dbm, Dbfs, Swr
    let kDegDenom: Float = 64.0             // denominator for Degc, Degf
    
    var meterIds = [UInt16]()
    
    if _metersAreStreaming == false {
      _metersAreStreaming = true
      log("Meter stream \(vita.streamId.hex): started", .info, #function, #file, #line)
    }
    
    // NOTE:  there is a bug in the Radio (as of v2.2.8) that sends
    //        multiple copies of meters, this code ignores the duplicates
    
    vita.payloadData.withUnsafeBytes { (payloadPtr) in
      // four bytes per Meter
      let numberOfMeters = Int(vita.payloadSize / 4)
      
      // pointer to the first Meter number / Meter value pair
      let ptr16 = payloadPtr.bindMemory(to: UInt16.self)
      
      // for each meter in the Meters packet
      for i in 0..<numberOfMeters {
        // get the Meter id and the Meter value
        let id: UInt16 = CFSwapInt16BigToHost(ptr16[2 * i])
        let value: UInt16 = CFSwapInt16BigToHost(ptr16[(2 * i) + 1])
        
        // is this a duplicate?
        if !meterIds.contains(id) {
          // NO, add it to the list
          meterIds.append(id)
          
          // find the meter (if present) & update it
          if let meter = _meters[id: id] {
            //          meter.streamHandler( value)
            let newValue = Int16(bitPattern: value)
            let previousValue = meter.value
            
            // check for unknown Units
            guard let token = Units(rawValue: meter.units) else {
              //      // log it and ignore it
              //      log("Meter \(desc) \(description) \(group) \(name) \(source): unknown units - \(units))", .warning, #function, #file, #line)
              return
            }
            var adjNewValue: Float = 0.0
            switch token {
              
            case .db, .dbm, .dbfs, .swr:        adjNewValue = Float(exactly: newValue)! / kDbDbmDbfsSwrDenom
            case .volts, .amps:                 adjNewValue = Float(exactly: newValue)! / 256.0
            case .degc, .degf:                  adjNewValue = Float(exactly: newValue)! / kDegDenom
            case .rpm, .watts, .percent, .none: adjNewValue = Float(exactly: newValue)!
            }
            // did it change?
            if adjNewValue != previousValue {
              _meters[id: id]!.value = adjNewValue
            }
            Meters.meterPublisher.send(meter)
          }
        }
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Meter Struct

public struct Meter: Identifiable, Equatable {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: MeterId
  
  public var initialized: Bool = false
  public var desc = ""
  public var fps = 0
  public var high: Float = 0
  public var low: Float = 0
  public var group = ""
  public var name = ""
  public var peak: Float = 0
  public var source = ""
  public var units = ""
  public var value: Float = 0

  public enum Source: String {
    case codec     = "cod"
    case tx
    case slice     = "slc"
    case radio     = "rad"
    case amplifier = "amp"
  }
  public enum ShortName : String, CaseIterable {
    case codecOutput       = "codec"
    case microphoneAverage = "mic"
    case microphoneOutput  = "sc_mic"
    case microphonePeak    = "micpeak"
    case postClipper       = "comppeak"
    case postFilter1       = "sc_filt_1"
    case postFilter2       = "sc_filt_2"
    case postGain          = "gain"
    case postRamp          = "aframp"
    case postSoftwareAlc   = "alc"
    case powerForward      = "fwdpwr"
    case powerReflected    = "refpwr"
    case preRamp           = "b4ramp"
    case preWaveAgc        = "pre_wave_agc"
    case preWaveShim       = "pre_wave"
    case signal24Khz       = "24khz"
    case signalPassband    = "level"
    case signalPostNrAnf   = "nr/anf"
    case signalPostAgc     = "agc+"
    case swr               = "swr"
    case temperaturePa     = "patemp"
    case voltageAfterFuse  = "+13.8b"
    case voltageBeforeFuse = "+13.8a"
    case voltageHwAlc      = "hwalc"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: MeterId) { self.id = id }
}
