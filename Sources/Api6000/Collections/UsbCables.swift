//
//  UsbCables.swift
//  
//
//  Created by Douglas Adams on 6/11/22.
//

import Foundation
import IdentifiedCollections

import ApiShared

public actor UsbCables {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
    
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

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _usbCables = IdentifiedArrayOf<UsbCable>()
  
  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = UsbCables()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func add(_ usbCable: UsbCable) {
    _usbCables[id: usbCable.id] = usbCable
    updateModel()
  }
  
  public func exists(id: UsbCableId) -> Bool {
    _usbCables[id: id] != nil
  }
  
  /// Parse a USB Cable status message
  /// - Parameters:
  ///   - properties:     a KeyValuesArray
  ///   - inUse:          false = "to be deleted"
  public func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id
    let id = properties[0].key
    
    // is the object in use?
    if inUse {
      // YES, does it exist?
      if !exists(id: id) {
        // NO, is it a valid cable type?
        if let cableType = UsbCable.UsbCableType(rawValue: properties[1].value) {
          // YES, create a new UsbCable & add it to the UsbCables collection
          add( UsbCable(id, cableType: cableType) )
          log("UsbCable \(id): added", .debug, #function, #file, #line)

        } else {
          // NO, log the error and ignore it
          log("USBCable invalid Type: \(properties[1].value)", .warning, #function, #file, #line)
          return
        }
      }
      // pass the remaining key values to the Usb Cable for parsing
      parseProperties( id, Array(properties.dropFirst(1)) )
      
    } else {
      remove(id)
    }
  }

  /// Remove a UsbCable
  /// - Parameter id:   a UsbCable Id
  public func remove(_ id: UsbCableId)  {
    _usbCables.remove(id: id)
    log("UsbCable \(id): removed", .debug, #function, #file, #line)

    updateModel()
  }
  
  /// Remove all UsbCables
  public func removeAll()  {
    for usbCable in _usbCables {
      remove(usbCable.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Parse USB Cable key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private func parseProperties(_ id: UsbCableId, _ properties: KeyValuesArray) {
    // is the Status for a cable of this type?
    if _usbCables[id: id]?.cableType.rawValue == properties[0].value {
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
          
        case .autoReport:   _usbCables[id: id]?.autoReport = property.value.bValue
        case .band:         _usbCables[id: id]?.band = property.value
        case .cableType:    break   // FIXME:
        case .dataBits:     _usbCables[id: id]?.dataBits = property.value.iValue
        case .enable:       _usbCables[id: id]?.enable = property.value.bValue
        case .flowControl:  _usbCables[id: id]?.flowControl = property.value
        case .name:         _usbCables[id: id]?.name = property.value
        case .parity:       _usbCables[id: id]?.parity = property.value
        case .pluggedIn:    _usbCables[id: id]?.pluggedIn = property.value.bValue
        case .polarity:     _usbCables[id: id]?.polarity = property.value
        case .preamp:       _usbCables[id: id]?.preamp = property.value
        case .source:       _usbCables[id: id]?.source = property.value
        case .sourceRxAnt:  _usbCables[id: id]?.sourceRxAnt = property.value
        case .sourceSlice:  _usbCables[id: id]?.sourceSlice = property.value.iValue
        case .sourceTxAnt:  _usbCables[id: id]?.sourceTxAnt = property.value
        case .speed:        _usbCables[id: id]?.speed = property.value.iValue
        case .stopBits:     _usbCables[id: id]?.stopBits = property.value.iValue
        case .usbLog:       _usbCables[id: id]?.usbLog = property.value.bValue
        }
      }
      
    } else {
      // NO, log the error
      log("USBCable, status type: \(properties[0].key) != Cable type: \(_usbCables[id: id]?.cableType.rawValue ?? "")", .warning, #function, #file, #line)
    }
    
    // is it initialized?
    if _usbCables[id: id]?.initialized == false {
      // NO, it is now
      _usbCables[id: id]?.initialized = true
      log("USBCable \(id): initialized ", .debug, #function, #file, #line)
    }
    updateModel()
  }

  private func updateModel() {
    Task {
      await Model.shared.setUsbCables(_usbCables)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Send a command to Set a UsbCable property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified UsbCable
  ///   - token:      the parse token
  ///   - value:      the new value
  private static nonisolated func sendCommand(_ radio: Radio, _ id: UsbCableId, _ token: UsbCableToken, _ value: Any) {
    radio.send("usb_cable set " + "\(id) " + token.rawValue + "=\(value)")
  }
}

// ----------------------------------------------------------------------------
// MARK: - UsbCable Struct

public struct UsbCable: Identifiable {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: UsbCableId
  public let cableType: UsbCableType

  public var initialized = false
  public var autoReport = false
  public var band = ""
  public var dataBits = 0
  public var enable = false
  public var flowControl = ""
  public var name = ""
  public var parity = ""
  public var pluggedIn = false
  public var polarity = ""
  public var preamp = ""
  public var source = ""
  public var sourceRxAnt = ""
  public var sourceSlice = 0
  public var sourceTxAnt = ""
  public var speed = 0
  public var stopBits = 0
  public var usbLog = false
  
  public enum UsbCableType: String {
    case bcd
    case bit
    case cat
    case dstar
    case invalid
    case ldpa
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: UsbCableId, cableType: UsbCableType) {
    self.id = id
    self.cableType = cableType
  }
}

