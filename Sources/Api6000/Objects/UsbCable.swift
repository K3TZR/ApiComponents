//
//  UsbCable.swift
//  Components6000/Radio/Objects
//
//  Created by Douglas Adams on 6/25/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation

import Shared

// USB Cable Class implementation
//
//      creates a USB Cable instance to be used by a Client to support the
//      processing of USB connections to the Radio (hardware). USB Cable structs
//      are added, removed and updated by the incoming TCP messages. They are
//      collected in the Model.usbCables collection

public struct UsbCable: Identifiable {
  // ----------------------------------------------------------------------------
  // MARK: - Published properties
  
  public internal(set) var id: UsbCableId
  public internal(set) var initialized = false

  public internal(set) var autoReport = false
  public internal(set) var band = ""
  public internal(set) var dataBits = 0
  public internal(set) var enable = false
  public internal(set) var flowControl = ""
  public internal(set) var name = ""
  public internal(set) var parity = ""
  public internal(set) var pluggedIn = false
  public internal(set) var polarity = ""
  public internal(set) var preamp = ""
  public internal(set) var source = ""
  public internal(set) var sourceRxAnt = ""
  public internal(set) var sourceSlice = 0
  public internal(set) var sourceTxAnt = ""
  public internal(set) var speed = 0
  public internal(set) var stopBits = 0
  public internal(set) var usbLog = false
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public private(set) var cableType         : UsbCableType
  public enum UsbCableType: String {
    case bcd
    case bit
    case cat
    case dstar
    case invalid
    case ldpa
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Internal properties
  
  public enum UsbCableToken: String {
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
  
  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: UsbCableId, cableType: UsbCableType) {
    self.id = id
    self.cableType = cableType
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Command methods
  
  /// Remove this UsbCable
  /// - Parameters:
  ///   - callback:           ReplyHandler (optional)
  ///
  //    public func remove(callback: ReplyHandler? = nil){
  //        _api.send("usb_cable " + "remove" + " \(id)")
  //    }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Command methods
  
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Parse a USB Cable status message
  /// - Parameters:
  ///   - properties:     a KeyValuesArray
  ///   - inUse:          false = "to be deleted"
  public static func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id
    let id = properties[0].key
    
    // is the object in use?
    if inUse {
      // YES, does it exist?
      if Model.shared.usbCables[id: id] == nil {
        // NO, is it a valid cable type?
        if let cableType = UsbCable.UsbCableType(rawValue: properties[1].value) {
          // YES, create a new UsbCable & add it to the UsbCables collection
          Model.shared.usbCables[id: id] = UsbCable(id, cableType: cableType)
          log("UsbCable \(id): added", .debug, #function, #file, #line)

        } else {
          // NO, log the error and ignore it
          log("USBCable invalid Type: \(properties[1].value)", .warning, #function, #file, #line)
          return
        }
      }
      // pass the remaining key values to the Usb Cable for parsing
      Model.shared.usbCables[id: id]?.parseProperties( Array(properties.dropFirst(1)) )
      
    } else {
      // does the object exist?
      if Model.shared.usbCables[id: id] != nil {
        // YES, remove it, notify observers
        
        Model.shared.usbCables[id: id] = nil
        
        log("USBCable removed: id = \(id)", .debug, #function, #file, #line)
      }
    }
  }

  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         a UsbCable Id
  ///   - property:   a UsbCable Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, _ id: UsbCableId, property: UsbCableToken, value: Any) {
    // FIXME:
  }

//  public static func getProperty( _ id: TnfId, property: TnfToken) -> Any? {
//    switch property {
//    case .depth:       return Model.shared.tnfs[id: id]?.depth as Any
//    case .frequency:   return Model.shared.tnfs[id: id]?.frequency as Any
//    case .permanent:   return Model.shared.tnfs[id: id]?.permanent as Any
//    case .width:       return Model.shared.tnfs[id: id]?.width as Any
//    }
//  }
  
  /// Remove a UsbCable
  /// - Parameter id:   a UsbCable Id
  public static func remove(_ id: UsbCableId)  {
    Model.shared.usbCables.remove(id: id)
    log("UsbCable \(id): removed", .debug, #function, #file, #line)
  }
  
  /// Remove all usbCables
  public static func removeAll()  {
    for usbCable in Model.shared.usbCables {
      remove(usbCable.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Parse USB Cable key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private mutating func parseProperties(_ properties: KeyValuesArray) {
    // is the Status for a cable of this type?
    if cableType.rawValue == properties[0].value {
      // YES,
      // process each key/value pair, <key=value>
      for property in properties {
        // check for unknown Keys
        guard let token = UsbCableToken(rawValue: property.key) else {
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
  private static func sendCommand(_ radio: Radio, _ id: UsbCableId, _ token: UsbCableToken, _ value: Any) {
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

