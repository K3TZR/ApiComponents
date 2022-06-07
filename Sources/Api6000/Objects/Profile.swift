//
//  Profile.swift
//  Api6000Components/Api6000/Objects
//
//  Created by Douglas Adams on 8/17/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation

import Shared

// Profile struct implementation
//      creates a Profiles instance to be used by a Client to support the
//      processing of the profiles. Profile structs are added, removed and
//      updated by the incoming TCP messages. They are collected in the
//      ProfilesCollection.

public struct Profile: Identifiable {
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public internal(set) var id: ProfileId
  public internal(set) var initialized = false

  public internal(set) var current: ProfileName = ""
  public internal(set) var list = [ProfileName]()
  
  public enum ProfileToken: String {
    case list       = "list"
    case current  = "current"
  }

  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: ProfileId) { self.id = id }

  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  /// Parse a Profile status message
  /// - Parameters:
  ///   - properties:     a KeyValuesArray of Profile properties
  ///   - inUse:          false = "to be deleted"
  public static func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool = true) {
    // get the Id
    let id = properties[0].key.valuesArray()[0]
    // is the object in use?
    if inUse {
      // YES, does it exist?
      if Model.shared.profiles[id: id] == nil {
        // NO, create a new Profile & add it to the Profiles collection
        Model.shared.profiles[id: id] = Profile(id)
        log("Profile \(id): added", .debug, #function, #file, #line)
      }
      // pass the remaining key values to the Amplifier for parsing
      var newProperties = properties
      newProperties[0].key = properties[0].key.valuesArray()[1]
      Model.shared.profiles[id: id]?.parseProperties(newProperties )
    } else {
      // NO, does it exist?
      if Model.shared.profiles[id: id] != nil {
        // YES, remove it
        remove(id)
      }
    }
  }

  public static func setProperty(radio: Radio, _ id: ProfileId, property: ProfileToken, value: Any) {
    // FIXME: add commands
  }

  public static func getProperty( _ id: ProfileId, property: ProfileToken) -> Any? {
    switch property {
    case .list:         return Model.shared.profiles[id: id]!.list as Any
    case .current:      return Model.shared.profiles[id: id]!.current as Any
    }
  }

  /// Remove the specified Profiles
  /// - Parameter id:     an ProfileId
  public static func remove(_ id: ProfileId) {
    Model.shared.profiles.remove(id: id)
    log("Profile \(id): removed", .debug, #function, #file, #line)
  }
  
  /// Remove all Profiles
  public static func removeAll() {
    for profile in Model.shared.profiles {
      remove(profile.id)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private Static methods
  
  /// Parse Profile key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  private mutating func parseProperties(_ properties: KeyValuesArray) {
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
      list = (temp.last == "" ? Array(temp.dropLast()) : temp)
      
    case .current:    current = properties[1].key
      
    }
    // is it initialized?
    if initialized == false {
      // NO, it is now
      initialized = true
      log("Profile \(id): initialized", .debug, #function, #file, #line)
    }
  }
  
  /// Send a command to Set a Profile property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Amplifier
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: ProfileId, _ token: ProfileToken, _ value: Any) {
    // FIXME: add commands
  }
}
