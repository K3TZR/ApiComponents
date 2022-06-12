//
//  Tnfs.swift
//  
//
//  Created by Douglas Adams on 6/9/22.
//

import Foundation
import IdentifiedCollections

import Shared

public actor Tnfs {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public enum TnfToken : String {
    case depth
    case frequency = "freq"
    case permanent
    case width
  }
  
  public enum Depth : UInt {
    case normal   = 1
    case deep     = 2
    case veryDeep = 3
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _tnfs = IdentifiedArrayOf<Tnf>()
  
  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = Tnfs()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func add(_ tnf: Tnf) {
    _tnfs[id: tnf.id] = tnf
    updateModel()
  }
  
  public func exists(id: TnfId) -> Bool {
    _tnfs[id: id] != nil
  }
  
  /// Parse a Tnf status message
  /// - Parameters:
  ///   - properties:     a KeyValuesArray of Tnf properties
  ///   - inUse:          false = "to be deleted"
  public func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) async {
    // Note: Tnf does not send status on removal
    
    // get the Id
    if let id = properties[0].key.objectId {
      // is the object in use?
      if inUse {
        // YES, does it exist?
        if !exists(id: id) {
          // NO, create a new Tnf & add it to the Tnfs collection
          //          Model.shared.tnfs[id: id] = Tnf(id)
          add( Tnf(id) )
          log("Tnf \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values to the Tnf for parsing
        //        Model.shared.tnfs[id: id]?.parseProperties( Array(properties.dropFirst(1)) )
        parseProperties( id, Array(properties.dropFirst(1)) )
      }
    }
  }
  
  /// Remove a Tnf
  /// - Parameter id:   a Tnf Id
  public func remove(_ id: TnfId)  {
   _tnfs.remove(id: id)
    log("Tnf \(id.hex): removed", .debug, #function, #file, #line)

    updateModel()
  }
  
  /// Remove all Tnfs
  public func removeAll()  {
    for tnf in _tnfs {
      remove(tnf.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Parse Tnf key/value pairs
  /// - Parameter properties: a KeyValuesArray
  private func parseProperties(_ id: TnfId, _ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = TnfToken(rawValue: property.key) else {
        // log it and ignore the Key
        log("Tnf \(id): unknown token \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // known keys
      switch token {
        
      case .depth:      _tnfs[id: id]?.depth = property.value.uValue
      case .frequency:  _tnfs[id: id]?.frequency = property.value.mhzToHz
      case .permanent:  _tnfs[id: id]?.permanent = property.value.bValue
      case .width:      _tnfs[id: id]?.width = property.value.mhzToHz
      }
      // is it initialized?
      if _tnfs[id: id]?.initialized == false && _tnfs[id: id]?.frequency != 0 {
        // NO, it is now
        _tnfs[id: id]?.initialized = true
        log("Tnf \(id): initialized frequency = \(_tnfs[id: id]!.frequency)", .debug, #function, #file, #line)
      }
    }
    updateModel()
  }

  private func updateModel() {
    Task {
      await Model.shared.setTnfs(_tnfs)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         a Tnf Id
  ///   - property:   a Tnf Token
  ///   - value:      the new value
  public static nonisolated func setProperty(radio: Radio, id: TnfId, property: TnfToken, value: Any) {
    switch property {
    case .depth:       sendCommand( radio, id, .depth, value)
    case .frequency:   sendCommand( radio, id, .frequency, (value as! Hz).hzToMhz)
    case .permanent:   sendCommand( radio, id, .permanent, (value as! Bool).as1or0)
    case .width:       sendCommand( radio, id, .width, (value as! Hz).hzToMhz)
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Send a command to Set a Tnf property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Tnf
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: TnfId, _ token: TnfToken, _ value: Any) {
    radio.send("tnf set " + "\(id) " + token.rawValue + "=\(value)")
  }
}

// ----------------------------------------------------------------------------
// MARK: - Tnf Struct

public struct Tnf: Identifiable, Equatable {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties

  public let id: TnfId
  
  public var initialized = false
  public var depth: UInt = 0
  public var frequency: Hz = 0
  public var permanent = false
  public var width: Hz = 0

  // ----------------------------------------------------------------------------
  // MARK: - Initialization

  public init(_ id: TnfId) { self.id = id }
}
