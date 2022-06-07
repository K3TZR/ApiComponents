//
//  Memory.swift
//  Api6000Components/Api6000/Objects
//
//  Created by Douglas Adams on 8/20/15.
//  Copyright © 2015 Douglas Adams. All rights reserved.
//

import Foundation

import Shared

// Memory Class implementation
//       creates a Memory instance to be used by a Client to support the
//       processing of a Memory. Memory structs are added, removed and
//       updated by the incoming TCP messages. They are collected in the
//       MemoriesCollection.

public struct Memory: Identifiable, Equatable {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public internal(set) var id: MemoryId
  public internal(set) var initialized = false

  public internal(set) var digitalLowerOffset = 0
  public internal(set) var digitalUpperOffset = 0
  public internal(set) var filterHigh = 0
  public internal(set) var filterLow = 0
  public internal(set) var frequency: Hz = 0
  public internal(set) var group = ""
  public internal(set) var mode = ""
  public internal(set) var name = ""
  public internal(set) var offset = 0
  public internal(set) var offsetDirection = ""
  public internal(set) var owner = ""
  public internal(set) var rfPower = 0
  public internal(set) var rttyMark = 0
  public internal(set) var rttyShift = 0
  public internal(set) var squelchEnabled = false
  public internal(set) var squelchLevel = 0
  public internal(set) var step = 0
  public internal(set) var toneMode = ""
  public internal(set) var toneValue: Float = 0
  
  public enum MemoryToken : String {
    case digitalLowerOffset         = "digl_offset"
    case digitalUpperOffset         = "digu_offset"
    case frequency                  = "freq"
    case group
    case highlight
    case highlightColor             = "highlight_color"
    case mode
    case name
    case owner
    case repeaterOffsetDirection    = "repeater"
    case repeaterOffset             = "repeater_offset"
    case rfPower                    = "power"
    case rttyMark                   = "rtty_mark"
    case rttyShift                  = "rtty_shift"
    case rxFilterHigh               = "rx_filter_high"
    case rxFilterLow                = "rx_filter_low"
    case step
    case squelchEnabled             = "squelch"
    case squelchLevel               = "squelch_level"
    case toneMode                   = "tone_mode"
    case toneValue                  = "tone_value"
  }

  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: MemoryId) { self.id = id }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  // Equality
  public static func == (lhs: Memory, rhs: Memory) -> Bool {
    lhs.id == rhs.id
  }
  
  /// Parse a Memory status message
  /// - Parameters:
  ///   - properties:     a KeyValuesArray of Memory properties
  ///   - inUse:          false = "to be deleted"
  public static func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id
    if let id = properties[0].key.objectId {
      // is the object in use?
      if inUse {
        // YES, does it exist?
        if Model.shared.memories[id: id] == nil {
          // NO, create a new Memory & add it to the Memories collection
          Model.shared.memories[id: id] = Memory(id)
          log("Memory \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values to the Memory for parsing
        Model.shared.memories[id: id]?.parseProperties( Array(properties.dropFirst(1)) )
      } else {
        if Model.shared.memories[id: id] != nil {
          remove(id)
        }
      }
    }
  }
  
  public static func setProperty(radio: Radio, _ id: MemoryId, property: MemoryToken, value: Any) {
    // FIXME: add commands
  }

  public static func getProperty( _ id: MemoryId, property: MemoryToken) -> Any? {
    switch property {
      
    case .digitalLowerOffset:       return Model.shared.memories[id: id]!.digitalLowerOffset as Any
    case .digitalUpperOffset:       return Model.shared.memories[id: id]!.digitalUpperOffset as Any
    case .frequency:                return Model.shared.memories[id: id]!.frequency as Any
    case .group:                    return Model.shared.memories[id: id]!.group as Any
    case .highlight:                return nil   // ignored here
    case .highlightColor:           return nil   // ignored here
    case .mode:                     return Model.shared.memories[id: id]!.mode as Any
    case .name:                     return Model.shared.memories[id: id]!.name as Any
    case .owner:                    return Model.shared.memories[id: id]!.owner as Any
    case .repeaterOffsetDirection:  return Model.shared.memories[id: id]!.offsetDirection as Any
    case .repeaterOffset:           return Model.shared.memories[id: id]!.offset as Any
    case .rfPower:                  return Model.shared.memories[id: id]!.rfPower as Any
    case .rttyMark:                 return Model.shared.memories[id: id]!.rttyMark as Any
    case .rttyShift:                return Model.shared.memories[id: id]!.rttyShift as Any
    case .rxFilterHigh:             return Model.shared.memories[id: id]!.filterHigh as Any
    case .rxFilterLow:              return Model.shared.memories[id: id]!.filterLow as Any
    case .squelchEnabled:           return Model.shared.memories[id: id]!.squelchEnabled as Any
    case .squelchLevel:             return Model.shared.memories[id: id]!.squelchLevel as Any
    case .step:                     return Model.shared.memories[id: id]!.step as Any
    case .toneMode:                 return Model.shared.memories[id: id]!.toneMode as Any
    case .toneValue:                return Model.shared.memories[id: id]!.toneValue as Any
    }
  }

  /// Remove the specified Memory
  /// - Parameter id:     a MemoryId
  public static func remove(_ id: MemoryId) {
    Model.shared.memories.remove(id: id)
    log("Memory \(id.hex): removed", .debug, #function, #file, #line)
  }
  
   /// Remove all Memories
  public static func removeAll() {
     for memory in Model.shared.memories {
       remove(memory.id)
     }
   }

  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Parse Tnf key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private mutating func parseProperties(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = MemoryToken(rawValue: property.key) else {
        // log it and ignore the Key
        log("Memory \(id.hex) unknown token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // known keys
      switch token {
        
      case .digitalLowerOffset:       digitalLowerOffset = property.value.iValue
      case .digitalUpperOffset:       digitalUpperOffset = property.value.iValue
      case .frequency:                frequency = property.value.mhzToHz
      case .group:                    group = property.value.replacingSpaces()
      case .highlight:                break   // ignored here
      case .highlightColor:           break   // ignored here
      case .mode:                     mode = property.value.replacingSpaces()
      case .name:                     name = property.value.replacingSpaces()
      case .owner:                    owner = property.value.replacingSpaces()
      case .repeaterOffsetDirection:  offsetDirection = property.value.replacingSpaces()
      case .repeaterOffset:           offset = property.value.iValue
      case .rfPower:                  rfPower = property.value.iValue
      case .rttyMark:                 rttyMark = property.value.iValue
      case .rttyShift:                rttyShift = property.value.iValue
      case .rxFilterHigh:             filterHigh = property.value.iValue
      case .rxFilterLow:              filterLow = property.value.iValue
      case .squelchEnabled:           squelchEnabled = property.value.bValue
      case .squelchLevel:             squelchLevel = property.value.iValue
      case .step:                     step = property.value.iValue
      case .toneMode:                 toneMode = property.value.replacingSpaces()
      case .toneValue:                toneValue = property.value.fValue
      }
      // is it initialized?
      if initialized == false {
        // NO, it is now
        initialized = true
        log("Memory \(id.hex): initialized", .debug, #function, #file, #line)
      }
    }
  }
  
  /// Send a command to Set a Memory property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Memory
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: MemoryId, _ token: MemoryToken, _ value: Any) {

    // FIXME: add commands
    
    //    radio.send("tnf set " + "\(id) " + token.rawValue + "=\(value)")
  }
}
