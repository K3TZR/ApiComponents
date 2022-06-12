//
//  Memories.swift
//  
//
//  Created by Douglas Adams on 6/11/22.
//

import Foundation
import IdentifiedCollections

import Shared

public actor Memories {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
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

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _memories = IdentifiedArrayOf<Memory>()
  
  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = Memories()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func add(_ memory: Memory) {
    _memories[id: memory.id] = memory
    updateModel()
  }
  
  public func exists(id: MemoryId) -> Bool {
    _memories[id: id] != nil
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
        if !exists(id: id) {
          // NO, create a new Memory & add it to the Memories collection
          add( Memory(id) )
          log("Memory \(id.hex): added", .debug, #function, #file, #line)
        }
        // pass the remaining key values to the Memory for parsing
        parseProperties( id, Array(properties.dropFirst(1)) )
      } else {
        remove(id)
      }
    }
  }

  /// Remove a Memory
  /// - Parameter id:   a Memory Id
  public func remove(_ id: MemoryId)  {
    _memories.remove(id: id)
    log("Memory \(id.hex): removed", .debug, #function, #file, #line)

    updateModel()
  }
  
  /// Remove all Memories
  public func removeAll()  {
    for memory in _memories {
      remove(memory.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Parse Tnf key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private func parseProperties(_ id: MemoryId, _ properties: KeyValuesArray) {
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
        
      case .digitalLowerOffset:       _memories[id: id]?.digitalLowerOffset = property.value.iValue
      case .digitalUpperOffset:       _memories[id: id]?.digitalUpperOffset = property.value.iValue
      case .frequency:                _memories[id: id]?.frequency = property.value.mhzToHz
      case .group:                    _memories[id: id]?.group = property.value.replacingSpaces()
      case .highlight:                break   // ignored here
      case .highlightColor:           break   // ignored here
      case .mode:                     _memories[id: id]?.mode = property.value.replacingSpaces()
      case .name:                     _memories[id: id]?.name = property.value.replacingSpaces()
      case .owner:                    _memories[id: id]?.owner = property.value.replacingSpaces()
      case .repeaterOffsetDirection:  _memories[id: id]?.offsetDirection = property.value.replacingSpaces()
      case .repeaterOffset:           _memories[id: id]?.offset = property.value.iValue
      case .rfPower:                  _memories[id: id]?.rfPower = property.value.iValue
      case .rttyMark:                 _memories[id: id]?.rttyMark = property.value.iValue
      case .rttyShift:                _memories[id: id]?.rttyShift = property.value.iValue
      case .rxFilterHigh:             _memories[id: id]?.filterHigh = property.value.iValue
      case .rxFilterLow:              _memories[id: id]?.filterLow = property.value.iValue
      case .squelchEnabled:           _memories[id: id]?.squelchEnabled = property.value.bValue
      case .squelchLevel:             _memories[id: id]?.squelchLevel = property.value.iValue
      case .step:                     _memories[id: id]?.step = property.value.iValue
      case .toneMode:                 _memories[id: id]?.toneMode = property.value.replacingSpaces()
      case .toneValue:                _memories[id: id]?.toneValue = property.value.fValue
      }
      // is it initialized?
      if _memories[id: id]?.initialized == false {
        // NO, it is now
        _memories[id: id]?.initialized = true
        log("Memory \(id.hex): initialized", .debug, #function, #file, #line)
      }
    }
    updateModel()
  }

  private func updateModel() {
    Task {
      await Model.shared.setMemories(_memories)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         a Memory Id
  ///   - property:   a Memory Token
  ///   - value:      the new value
  public static nonisolated func setProperty(radio: Radio, _ id: MemoryId, property: MemoryToken, value: Any) {
    // FIXME: add commands
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Send a command to Set a Memory property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Memory
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: MemoryId, _ token: MemoryToken, _ value: Any) {
    // FIXME: add commands
  }
}

// ----------------------------------------------------------------------------
// MARK: - Memory Struct

public struct Memory: Identifiable, Equatable {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: MemoryId
  
  public var initialized = false
  public var digitalLowerOffset = 0
  public var digitalUpperOffset = 0
  public var filterHigh = 0
  public var filterLow = 0
  public var frequency: Hz = 0
  public var group = ""
  public var mode = ""
  public var name = ""
  public var offset = 0
  public var offsetDirection = ""
  public var owner = ""
  public var rfPower = 0
  public var rttyMark = 0
  public var rttyShift = 0
  public var squelchEnabled = false
  public var squelchLevel = 0
  public var step = 0
  public var toneMode = ""
  public var toneValue: Float = 0
  
  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: MemoryId) { self.id = id }
}
