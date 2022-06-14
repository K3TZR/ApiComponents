//
//  Support.swift
//  UtilityComponents/Shared
//
//  Created by Douglas Adams on 10/23/21.
//

import Foundation

// ----------------------------------------------------------------------------
// MARK: - Constants

public let kVersionSupported = Version("3.2.34")
public let kConnected = "connected"
public let kDisconnected = "disconnected"
public let kNoError = "0"
public let kNotInUse = "in_use=0"
public let kRemoved = "removed"

// ----------------------------------------------------------------------------
// MARK: - Notifications

public let logEntryNotification = NSNotification.Name(rawValue: "LogEntry")
public let logAlertNotification = NSNotification.Name(rawValue: "LogAlert")
public let testNotification = NSNotification.Name(rawValue: "TestResult")

// ----------------------------------------------------------------------------
// MARK: - Structs & Enums

public enum LogLevel: String, CaseIterable {
    case debug
    case info
    case warning
    case error
}

public struct LogEntry: Equatable {
  public static func == (lhs: LogEntry, rhs: LogEntry) -> Bool {
    guard lhs.msg == rhs.msg else { return false }
    guard lhs.level == rhs.level else { return false }
    guard lhs.level == rhs.level else { return false }
    guard lhs.function.description == rhs.function.description else { return false }
    guard lhs.file.description == rhs.file.description else { return false }
    guard lhs.line == rhs.line else { return false }
    return true
  }
  
  public var msg: String
  public var level: LogLevel
  public var function: StaticString
  public var file: StaticString
  public var line: Int
  
  public init(_ msg: String, _ level: LogLevel, _ function: StaticString, _ file: StaticString, _ line: Int ) {
    self.msg = msg
    self.level = level
    self.function = function
    self.file = file
    self.line = line
  }
}

public enum ConnectionType: String, Equatable {
  case gui = "Radio"
  case nonGui = "Station"
}

//public struct PickerSelection: Equatable {
//  public init(_ packet: Packet, _ station: String? = nil, _ disconnectHandle: Handle? = nil) {
//    self.packet = packet
//    self.station = station
//    self.disconnectHandle = disconnectHandle
//  }
//
//  public var packet: Packet
//  public var station: String?
//  public var disconnectHandle: Handle?
//}

public enum ButtonType: Equatable {
  case primary(String)
  case secondary(String)
}

public struct AlertView: Equatable, Identifiable {
  
  public init(
    title: String,
    message: String? = nil,
    button1Text: String? = nil
//    button2: ButtonType? = nil
  )
  {
    self.title = title
    self.message = message
    self.button1Text = button1Text
//    self.button2 = button2
  }
  public var id: String { self.title }
  public var title: String
  public var message: String?
  public var button1Text: String?
//  public var button2: ButtonType?
}

/// Struct to hold a Semantic Version number
///     with provision for a Build Number
///
public struct Version {
  var major: Int = 1
  var minor: Int = 0
  var patch: Int = 0
  var build: Int = 1
  
  public init(_ versionString: String = "1.0.0") {
    let components = versionString.components(separatedBy: ".")
    switch components.count {
    case 3:
      major = Int(components[0]) ?? 1
      minor = Int(components[1]) ?? 0
      patch = Int(components[2]) ?? 0
      build = 1
    case 4:
      major = Int(components[0]) ?? 1
      minor = Int(components[1]) ?? 0
      patch = Int(components[2]) ?? 0
      build = Int(components[3]) ?? 1
    default:
      major = 1
      minor = 0
      patch = 0
      build = 1
    }
  }
  
  public init() {
    // only useful for Apps & Frameworks (which have a Bundle), not Packages
    let versions = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "?"
    let build   = Bundle.main.infoDictionary![kCFBundleVersionKey as String] as? String ?? "?"
    self.init(versions + ".\(build)")
  }
  
  public var longString: String { "\(major).\(minor).\(patch) (\(build))" }
  public var string: String { "\(major).\(minor).\(patch)" }
  
  public static func == (lhs: Version, rhs: Version) -> Bool { lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch }
  
  public static func < (lhs: Version, rhs: Version) -> Bool {
    switch (lhs, rhs) {
      
    case (let lhs, let rhs) where lhs == rhs: return false
    case (let lhs, let rhs) where lhs.major < rhs.major: return true
    case (let lhs, let rhs) where lhs.major == rhs.major && lhs.minor < rhs.minor: return true
    case (let lhs, let rhs) where lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch < rhs.patch: return true
    default: return false
    }
  }
  public static func >= (lhs: Version, rhs: Version) -> Bool {
    switch (lhs, rhs) {
      
    case (let lhs, let rhs) where lhs == rhs: return true
    case (let lhs, let rhs) where lhs.major > rhs.major: return true
    case (let lhs, let rhs) where lhs.major == rhs.major && lhs.minor > rhs.minor: return true
    case (let lhs, let rhs) where lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch > rhs.patch: return true
    default: return false
    }
  }
}

public enum WanStatusType {
  case connect
  case publicIp
  case settings
}

public struct WanStatus: Equatable {
  
  public init(
    _ type: WanStatusType,
    _ name: String?,
    _ callsign: String?,
    _ serial: String?,
    _ wanHandle: String?,
    _ publicIp: String?
  )
  {
    self.type = type
    self.name = name
    self.callsign = callsign
    self.serial = serial
    self.wanHandle = wanHandle
    self.publicIp = publicIp
  }
  
  public var type: WanStatusType
  public var name: String?
  public var callsign: String?
  public var serial: String?
  public var wanHandle: String?
  public var publicIp: String?
}

public enum WanListenerError: Error {
  case kFailedToObtainIdToken
  case kFailedToConnect
}

public struct SmartlinkTestResult: Equatable {
  public var upnpTcpPortWorking = false
  public var upnpUdpPortWorking = false
  public var forwardTcpPortWorking = false
  public var forwardUdpPortWorking = false
  public var natSupportsHolePunch = false
  public var radioSerial = ""
  
  public init() {}
  
  // format the result as a String
  public var result: String {
        """
        Forward Tcp Port:\t\t\(forwardTcpPortWorking)
        Forward Udp Port:\t\t\(forwardUdpPortWorking)
        UPNP Tcp Port:\t\t\(upnpTcpPortWorking)
        UPNP Udp Port:\t\t\(upnpUdpPortWorking)
        Nat Hole Punch:\t\t\(natSupportsHolePunch)
        """
  }
  
  // result was Success / Failure
  public var success: Bool {
    (
      forwardTcpPortWorking == true &&
      forwardUdpPortWorking == true &&
      upnpTcpPortWorking == false &&
      upnpUdpPortWorking == false &&
      natSupportsHolePunch  == false) ||
    (
      forwardTcpPortWorking == false &&
      forwardUdpPortWorking == false &&
      upnpTcpPortWorking == true &&
      upnpUdpPortWorking == true &&
      natSupportsHolePunch  == false)
  }
}
