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
@MainActor
public class Profile: Identifiable, Equatable, ObservableObject {
  // Equality
  public nonisolated static func == (lhs: Profile, rhs: Profile) -> Bool {
    lhs.id == rhs.id
  }

  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: ProfileId) { self.id = id }

  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: ProfileId
  public var initialized = false

  @Published public var current: ProfileName = ""
  @Published public var list = [ProfileName]()
  
  public enum Property: String {
    case list       = "list"
    case current  = "current"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Instance methods
  
  /// Parse Profile key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) async {
    // check for incomplete properties
    guard properties.count == 2 else { return }
    // check for unknown Key
    guard let token = Property(rawValue: properties[0].key) else {
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

  
  
  
  
  
  
  
  public static func setProperty(radio: Radio, _ id: ProfileId, property: Property, value: Any) {
    // FIXME: add commands
  }

  public static func getProperty( _ id: ProfileId, property: Property) -> Any? {
    switch property {
    case .list:         return Model.shared.profiles[id: id]!.list as Any
    case .current:      return Model.shared.profiles[id: id]!.current as Any
    }
  }

  /// Send a command to Set a Profile property
  /// - Parameters:
  ///   - radio:      a Radio instance
  ///   - id:         the Id for the specified Amplifier
  ///   - token:      the parse token
  ///   - value:      the new value
  private static func sendCommand(_ radio: Radio, _ id: ProfileId, _ token: Property, _ value: Any) {
    // FIXME: add commands
  }
}
