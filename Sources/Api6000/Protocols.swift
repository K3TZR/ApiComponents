//
//  Protocols.swift
//  Api6000Components/Api6000
//
//  Created by Douglas Adams on 5/20/18.
//  Copyright © 2018 Douglas Adams. All rights reserved.
//

import Foundation
import Shared
import Vita

// --------------------------------------------------------------------------------
// MARK: - Protocols

/// Models for which there will only be one instance
///   Static Model objects are created / destroyed in the Radio class.
///   Static Model object properties are set in the instance's parseProperties method.
protocol StaticModel: AnyObject {
  /// Parse <key=value> arrays to set object properties
  /// - Parameters:
  ///   - radio:          a reference to the Radio object
  ///   - properties:     a KeyValues array containing object property values
  func parseProperties(_ properties: KeyValuesArray)
}

/// Models for which there can be multiple instances
///   Dynamic Model objects are created / destroyed in the Model's parseStatus static method.
///   Dynamic Model object properties are set in the instance's parseProperties method.
protocol DynamicModel: StaticModel {
  associatedtype IdType
  var id: IdType {get}
  /// Parse <key=value> arrays to determine object status
  /// - Parameters:
  ///   - keyValues:  a KeyValues array containing a Status message for an object type
  ///   - radio:      the current Radio object
  ///   - inUse:      a flag indicating whether the object in the status message is active
  static func parseStatus(_ properties: KeyValuesArray, _ inUse: Bool)
}

/// Dynamic models which have an accompanying UDP Stream
///   Some Dynamic Models have associated with them a UDP data stream & must
///   provide a method to process the Vita packets from the UDP stream
protocol DynamicModelWithStream: DynamicModel {
  /// Process vita packets
  /// - Parameter vitaPacket: a Vita packet
  func vitaProcessor(_ vitaPacket: Vita)
}

/// UDP Stream handler protocol
public protocol StreamHandler: AnyObject {
  /// Process a frame of Stream data
  /// - Parameter frame:        a frame of data
  func streamHandler<T>(_ frame: T)
}
