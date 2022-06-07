//
//  Meter.swift
//  Api6000Components/Api6000/Objects
//
//  Created by Douglas Adams on 6/2/15.
//  Copyright (c) 2015 Douglas Adams, K3TZR
//

import Foundation
import Combine

import Shared
import Vita

/// Meter Struct implementation
///
///      A Meter instance to be used by a Client to support the
///      rendering of a Meter. They are collected in the
///      metersCollection global actor.
///
public struct Meter: Identifiable, Equatable {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public internal(set) var id: MeterId
  public internal(set) var initialized: Bool = false

  public internal(set) var _desc = ""
  public internal(set) var _fps = 0
  public internal(set) var _high: Float = 0
  public internal(set) var _low: Float = 0
  public internal(set) var _group = ""
  public internal(set) var _name = ""
  public internal(set) var _peak: Float = 0
  public internal(set) var _source = ""
  public internal(set) var _units = ""
  public internal(set) var _value: Float = 0

  
  
  
  
  
  
  public var desc : String {
    get { Model.q.sync { _desc }}
    set { Model.q.sync(flags: .barrier) { _desc = newValue }}}
  public var fps : Int {
    get { Model.q.sync { _fps }}
    set { Model.q.sync(flags: .barrier) { _fps = newValue }}}
  public var high : Float {
    get { Model.q.sync { _high }}
    set { Model.q.sync(flags: .barrier) { _high = newValue }}}
  public var low : Float {
    get { Model.q.sync { _low }}
    set { Model.q.sync(flags: .barrier) { _low = newValue }}}
  public var group : String {
    get { Model.q.sync { _group }}
    set { Model.q.sync(flags: .barrier) { _group = newValue }}}
  public var name : String {
    get { Model.q.sync { _name }}
    set { Model.q.sync(flags: .barrier) { _name = newValue }}}
  public var peak : Float {
    get { Model.q.sync { _peak }}
    set { Model.q.sync(flags: .barrier) { _peak = newValue }}}
  public var source : String {
    get { Model.q.sync { _source }}
    set { Model.q.sync(flags: .barrier) { _source = newValue }}}
  public var units : String {
    get { Model.q.sync { _units }}
    set { Model.q.sync(flags: .barrier) { _units = newValue }}}
  public var value : Float {
    get { Model.q.sync { _value }}
    set { Model.q.sync(flags: .barrier) { _value = newValue }}}

  
  
  
  
  
  public static var meterPublisher = PassthroughSubject<Meter, Never>()
  public static var metersAreStreaming = false
  
  public enum Source: String {
    case codec      = "cod"
    case tx
    case slice      = "slc"
    case radio      = "rad"
    case amplifier  = "amp"
  }
  public enum ShortName : String, CaseIterable {
    case codecOutput            = "codec"
    case microphoneAverage      = "mic"
    case microphoneOutput       = "sc_mic"
    case microphonePeak         = "micpeak"
    case postClipper            = "comppeak"
    case postFilter1            = "sc_filt_1"
    case postFilter2            = "sc_filt_2"
    case postGain               = "gain"
    case postRamp               = "aframp"
    case postSoftwareAlc        = "alc"
    case powerForward           = "fwdpwr"
    case powerReflected         = "refpwr"
    case preRamp                = "b4ramp"
    case preWaveAgc             = "pre_wave_agc"
    case preWaveShim            = "pre_wave"
    case signal24Khz            = "24khz"
    case signalPassband         = "level"
    case signalPostNrAnf        = "nr/anf"
    case signalPostAgc          = "agc+"
    case swr                    = "swr"
    case temperaturePa          = "patemp"
    case voltageAfterFuse       = "+13.8b"
    case voltageBeforeFuse      = "+13.8a"
    case voltageHwAlc           = "hwalc"
  }

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
  // MARK: - Initialization
  
  public init(_ id: MeterId) { self.id = id }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  // Equality
  public static func == (lhs: Meter, rhs: Meter) -> Bool {
    lhs.id == rhs.id
  }

  /// Parse a Meter status message
  /// - Parameters:
  ///   - properties:     a KeyValuesArray of Meter properties
  ///   - inUse:          false = "to be deleted"
  public static func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // is the object in use?
    if inUse {
      // YES, extract the Meter Number from the first KeyValues entry
      let components = properties[0].key.components(separatedBy: ".")
      if components.count != 2 {return }
      
      // get the id
      if let id = components[0].objectId {
        // does the meter exist?
        
        if Model.shared.meters[id: id] == nil {
          // NO, create a new Meter & add it to the Meters collection
          Model.shared.meters[id: id] = Meter(id)
          log("Meter \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the key values to the Meter for parsing
        Model.shared.meters[id: id]?.parseProperties( properties )
      }
      
    } else {
      // NO, get the Id
      if let id = properties[0].key.components(separatedBy: " ")[0].objectId {
        remove(id)
      }
    }
  }
  
  /// Set the value of a Meter
  /// - Parameters:
  ///   - id:         the MeterId of the specified meter
  ///   - value:      the current value
  public static func setValue(_ id: MeterId, value: Float) {
    Model.shared.meters[id: id]!.value = value
  }
  
  /// Remove the specified Meter
  /// - Parameter id:     a MeterId
  public static func remove(_ id: MeterId) {
    Model.shared.meters.remove(id: id)
    log("Meter \(id): removed", .debug, #function, #file, #line)
  }
  
  /// Remove all Meters
  public static func removeAll() {
    for meter in Model.shared.meters {
      remove(meter.id)
    }
  }

  /// Process the Vita struct containing Meter data
  /// - Parameters:
  ///   - vita:        a Vita struct
  public static func vitaProcessor(_ vita: Vita) {
    let kDbDbmDbfsSwrDenom: Float = 128.0   // denominator for Db, Dbm, Dbfs, Swr
    let kDegDenom: Float = 64.0             // denominator for Degc, Degf
    
    var meterIds = [UInt16]()
    
    if metersAreStreaming == false {
      metersAreStreaming = true
      // log the start of the stream
      //      LogProxy.sharedInstance.log("Meter stream \(vita.streamId.hex): started", .info, #function, #file, #line)
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
          if let meter = Model.shared.meters[id: id] {
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
              Model.shared.meters[id: id]?.value = adjNewValue
            }
            meterPublisher.send(meter)
          }
        }
      }
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Parse Meter key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private mutating func parseProperties(_ properties: KeyValuesArray) {
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
        
      case .desc:     desc = property.value
      case .fps:      fps = property.value.iValue
      case .high:     high = property.value.fValue
      case .low:      low = property.value.fValue
      case .name:     name = property.value.lowercased()
      case .group:    group = property.value
      case .source:   source = property.value.lowercased()
      case .units:    units = property.value.lowercased()
      }
    }
    // is it initialized?
    if initialized == false && group != "" && units != "" {
      //NO, it is now
      initialized = true
      log("Meter \(id): initialized \(name), source = \(source), group = \(group)", .debug, #function, #file, #line)
    }
  }
}
