//
//  Profiles.swift
//  
//
//  Created by Douglas Adams on 6/11/22.
//

import Foundation
import IdentifiedCollections

import ApiShared

public actor Profiles {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public enum ProfileToken: String {
    case list    = "list"
    case current = "current"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _profiles = IdentifiedArrayOf<Profile>()
  
  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = Profiles()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func add(_ profile: Profile) {
    _profiles[id: profile.id] = profile
    updateModel()
  }
  
  public func exists(id: ProfileId) -> Bool {
    _profiles[id: id] != nil
  }
  
  /// Parse a Profile status message
  /// - Parameters:
  ///   - properties:     a KeyValuesArray of Profile properties
  ///   - inUse:          false = "to be deleted"
  public func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id
    let id = properties[0].key.valuesArray()[0]
    // is the object in use?
    if inUse {
      // YES, does it exist?
      if !exists(id: id) {
        // NO, create a new Profile & add it to the Profiles collection
        add( Profile(id) )
        log("Profile \(id): added", .debug, #function, #file, #line)
      }
      // pass the remaining key values to the Amplifier for parsing
      var newProperties = properties
      newProperties[0].key = properties[0].key.valuesArray()[1]
      parseProperties( id, newProperties )
    } else {
      remove(id)
    }
  }

  /// Remove a Profile
  /// - Parameter id:   a Profile Id
  public func remove(_ id: ProfileId)  {
   _profiles.remove(id: id)
    log("Profile \(id): removed", .debug, #function, #file, #line)

    updateModel()
  }
  
  /// Remove all Profiles
  public func removeAll()  {
    for profile in _profiles {
      remove(profile.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Parse Profile key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private func parseProperties(_ id: ProfileId, _ properties: KeyValuesArray) {
    // check for incomplete properties
    guard properties.count == 2 else { return }
    // check for unknown Key
    guard let token = ProfileToken(rawValue: properties[0].key) else {
      // log it and ignore the Key
      log("Profile \(id) unknown token: \(properties[0].key) = \(properties[1].key)", .warning, #function, #file, #line)
      return
    }
    // known keys
    switch token {
    case .list:
      let temp = Array(properties[1].key.valuesArray( delimiter: "^" ))
      _profiles[id: id]?.list = (temp.last == "" ? Array(temp.dropLast()) : temp)
      
    case .current:    _profiles[id: id]?.current = properties[1].key
      
    }
    // is it initialized?
    if _profiles[id: id]?.initialized == false {
      // NO, it is now
      _profiles[id: id]?.initialized = true
      log("Profile \(id): initialized", .debug, #function, #file, #line)
    }
    updateModel()
  }

  private func updateModel() {
    Task {
      await Model.shared.setProfiles(_profiles)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  /// Set a property
  /// - Parameters:
  ///   - radio:      the current radio
  ///   - id:         a Profile Id
  ///   - property:   a Profile Token
  ///   - value:      the new value
  public static func setProperty(radio: Radio, _ id: ProfileId, property: ProfileToken, value: Any) {
    // FIXME: add commands
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Send a command to Set a Profile property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Profile
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: ProfileId, _ token: ProfileToken, _ value: Any) {
    // FIXME: add commands
  }
}

// ----------------------------------------------------------------------------
// MARK: - Profile Struct

public struct Profile: Identifiable {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: ProfileId
  
  public var initialized = false
  public var current: ProfileName = ""
  public var list = [ProfileName]()
  
  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: ProfileId) { self.id = id }
}
