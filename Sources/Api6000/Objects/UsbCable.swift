//
//  UsbCable.swift
//  Api6000Components/Api6000/Objects
//
//  Created by Douglas Adams on 6/25/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation

import Shared

// USB Cable
//      creates a USB Cable instance to be used by a Client to support the
//      processing of USB connections to the Radio (hardware). USB Cable instances
//      are added, removed and updated by the incoming TCP messages. They are
//      collected in the Model.usbCables collection
@MainActor
public class UsbCable: Identifiable, Equatable, ObservableObject {
  // Equality
  public nonisolated static func == (lhs: UsbCable, rhs: UsbCable) -> Bool {
    lhs.id == rhs.id
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: UsbCableId) {
    self.id = id
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: UsbCableId
  public var initialized = false

  @Published public var autoReport = false
  @Published public var band = ""
  @Published public var dataBits = 0
  @Published public var enable = false
  @Published public var flowControl = ""
  @Published public var name = ""
  @Published public var parity = ""
  @Published public var pluggedIn = false
  @Published public var polarity = ""
  @Published public var preamp = ""
  @Published public var source = ""
  @Published public var sourceRxAnt = ""
  @Published public var sourceSlice = 0
  @Published public var sourceTxAnt = ""
  @Published public var speed = 0
  @Published public var stopBits = 0
  @Published public var usbLog = false
  
  public private(set) var cableType: UsbCableType = .bcd
  public enum UsbCableType: String {
    case bcd
    case bit
    case cat
    case dstar
    case invalid
    case ldpa
  }
  
  public enum Property: String {
    case autoReport  = "auto_report"
    case band
    case cableType   = "type"
    case dataBits    = "data_bits"
    case enable
    case flowControl = "flow_control"
    case name
    case parity
    case pluggedIn   = "plugged_in"
    case polarity
    case preamp
    case source
    case sourceRxAnt = "source_rx_ant"
    case sourceSlice = "source_slice"
    case sourceTxAnt = "source_tx_ant"
    case speed
    case stopBits    = "stop_bits"
    case usbLog      = "log"
    //        case usbLogLine = "log_line"
  }


  // ----------------------------------------------------------------------------
  // MARK: - Public Instance methods
  
  /// Parse key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) async {
    // is the Status for a cable of this type?
    if cableType.rawValue == properties[0].value {
      // YES,
      // process each key/value pair, <key=value>
      for property in properties {
        // check for unknown Keys
        guard let token = Property(rawValue: property.key) else {
          // log it and ignore the Key
          log("USBCable, unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
          continue
        }
        // Known keys, in alphabetical order
        switch token {
          
        case .autoReport:   autoReport = property.value.bValue
        case .band:         band = property.value
        case .cableType:    break   // FIXME:
        case .dataBits:     dataBits = property.value.iValue
        case .enable:       enable = property.value.bValue
        case .flowControl:  flowControl = property.value
        case .name:         name = property.value
        case .parity:       parity = property.value
        case .pluggedIn:    pluggedIn = property.value.bValue
        case .polarity:     polarity = property.value
        case .preamp:       preamp = property.value
        case .source:       source = property.value
        case .sourceRxAnt:  sourceRxAnt = property.value
        case .sourceSlice:  sourceSlice = property.value.iValue
        case .sourceTxAnt:  sourceTxAnt = property.value
        case .speed:        speed = property.value.iValue
        case .stopBits:     stopBits = property.value.iValue
        case .usbLog:       usbLog = property.value.bValue
        }
      }
      
    } else {
      // NO, log the error
      log("USBCable, status type: \(properties[0].key) != Cable type: \(cableType.rawValue)", .warning, #function, #file, #line)
    }
    
    // is it initialized?
    if initialized == false {
      // NO, it is now
      initialized = true
      log("USBCable \(id): initialized ", .debug, #function, #file, #line)
    }
  }

  
  
  
  
  
  
  
  
  
  
  
  /// Send a command to Set a UsbCable property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified UsbCable
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: UsbCableId, _ token: Property, _ value: Any) {
    radio.send("usb_cable set " + "\(id) " + token.rawValue + "=\(value)")
  }

  /// Send a command to Set a USB Cable property
  /// - Parameters:
  ///   - token:      the parse token
  ///   - value:      the new value
  ///
  //    private func usbCableCmd(_ token: UsbCableTokens, _ value: Any) {
  //    }
}

